{-# OPTIONS_GHC -fno-specialize #-}

module Hydra.Contract.Util where

import Plutus.V2.Ledger.Api (
  CurrencySymbol,
  TokenName (..),
  Value (getValue),
 )
import qualified PlutusTx.AssocMap as Map
import PlutusTx.Prelude

hydraHeadV1 :: BuiltinByteString
hydraHeadV1 = "HydraHeadV1"

-- | Checks that the output contains the ST token with the head 'CurrencySymbol'
-- and 'TokenName' of 'hydraHeadV1'
hasST :: CurrencySymbol -> Value -> Bool
hasST headPolicyId v =
  isJust $
    find
      (\(cs, tokenMap) -> cs == headPolicyId && hasHydraToken tokenMap)
      (Map.toList $ getValue v)
 where
  hasHydraToken tm =
    isJust $ find (\(tn, q) -> q == 1 && TokenName hydraHeadV1 == tn) (Map.toList tm)
{-# INLINEABLE hasST #-}
