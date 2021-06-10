{-# LANGUAGE TypeApplications #-}

module Hydra.HeadLogicSpec where

import Cardano.Prelude

import Control.Monad.Fail (
  fail,
 )
import qualified Data.Set as Set
import Hydra.HeadLogic (
  ClientResponse (NodeConnectedToNetwork),
  Effect (ClientEffect),
  Environment (..),
  Event (..),
  HeadParameters (..),
  HeadState (..),
  HeadStatus (OpenState),
  HydraMessage (..),
  Outcome (..),
  SimpleHeadState (..),
  SnapshotStrategy (..),
  update,
 )
import Hydra.Ledger (Ledger (initLedgerState), Party, Tx)
import Hydra.Ledger.Mock (MockTx (ValidTx), mockLedger)
import Test.Hspec (
  Spec,
  describe,
  expectationFailure,
  it,
  shouldBe,
 )
import Test.Hspec.Core.Spec (pending)

spec :: Spec
spec = describe "Hydra Head Logic" $ do
  let threeParties = Set.fromList [1, 2, 3]
      ledger = mockLedger
      env =
        Environment
          { party = 2
          , snapshotStrategy = NoSnapshots
          }

  it "confirms tx given it receives AckTx from all parties" $ do
    let reqTx = NetworkEvent $ ReqTx (ValidTx 1)
        ackFrom1 = NetworkEvent $ AckTx 1 (ValidTx 1)
        ackFrom2 = NetworkEvent $ AckTx 2 (ValidTx 1)
        ackFrom3 = NetworkEvent $ AckTx 3 (ValidTx 1)
        s0 = initialState threeParties ledger

    s1 <- assertNewState $ update env ledger s0 reqTx
    s2 <- assertNewState $ update env ledger s1 ackFrom3
    s3 <- assertNewState $ update env ledger s2 ackFrom1

    confirmedTransactions s3 `shouldBe` []

    s4 <- assertNewState $ update env ledger s3 ackFrom2

    confirmedTransactions s4 `shouldBe` [ValidTx 1]

  it "notifies client when it receives a ping" $ do
    update env ledger (initialState threeParties ledger) (NetworkEvent $ Ping 2) `hasEffect` ClientEffect (NodeConnectedToNetwork 2)

  it "does not confirm snapshots from non-leaders" pending
  it "does not confirm old snapshots" pending

hasEffect :: Tx tx => Outcome tx -> Effect tx -> IO ()
hasEffect (NewState _ effects) effect
  | effect `elem` effects = pure ()
  | otherwise = expectationFailure $ "Missing effect " <> show effect <> " in produced effects:  " <> show effects
hasEffect _ _ = expectationFailure $ "Unexpected outcome"

initialState ::
  Ord tx =>
  Set Party ->
  Ledger tx ->
  HeadState tx
initialState parties ledger =
  HeadState
    { headStatus = OpenState $ SimpleHeadState (initLedgerState ledger) mempty mempty 0
    , headParameters =
        HeadParameters
          { contestationPeriod = 42
          , parties
          }
    }

confirmedTransactions :: HeadState tx -> [tx]
confirmedTransactions HeadState{headStatus} = case headStatus of
  OpenState SimpleHeadState{confirmedTxs} -> confirmedTxs
  _ -> []

assertNewState :: Outcome MockTx -> IO (HeadState MockTx)
assertNewState = \case
  NewState st _ -> pure st
  Error e -> fail (show e)
  Wait -> fail "Found 'Wait'"
