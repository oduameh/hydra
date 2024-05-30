# Getting started
To get started quickly, we'll walk you through the standard demo setup, which includes:

* A cluster of three `hydra-node` directly connected to each other, each having access to one of three Hydra credentials: `Alice`, `Bob`, or `Carol`;
* A single `cardano-node` producing blocks used as a (very fast) local `devnet`;
* The `hydra-tui` example clients to interact with the individual `hydra-node`.

This tutorial uses [Docker](https://www.docker.com/get-started) to install the nodes, so ensure Docker is installed. If you want to explore alternative ways of running the tools, see the [variant tutorial](https://hydra.family/head-protocol/unstable/docs/getting-started-without-docker) or the [testnet tutorial](https://hydra.family/head-protocol/unstable/docs/tutorial/), which uses pre-built binaries. The documentation pages on [installation](https://hydra.family/head-protocol/unstable/docs/installation) and [configuration](https://hydra.family/head-protocol/unstable/docs/configuration) provide more details.

Additionally, the `hydra-tui` uses the HTTP/WebSocket API provided by the `hydra-node` behind the scenes. The [testnet tutorial](https://hydra.family/head-protocol/unstable/docs/tutorial/) will show how to use this API using low-level commands, or you can see the [API reference](https://hydra.family/head-protocol/unstable/api-reference) for more details.

<details>
<summary>Video demonstration (a bit dated)</summary>

<iframe style={{width: '100%', height: '480px'}} src="https://www.youtube.com/embed/dJk5_kB3BM4" title="Hydra Head Demo" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen="true"></iframe>

</details>

:::caution OS Compatibility
These instructions have been tested only on Linux environments (Ubuntu, NixOS). If you're on Windows or Mac OS X, you might need to adapt to use [Volumes](https://docs.docker.com/storage/volumes/).
:::

## Preparation

All commands below are written as if executed from the `demo` folder in the project repository. Ensure you clone the repository, switch into the `demo` folder, and pull the latest Docker images:

```shell
git clone git@github.com:input-output-hk/hydra.git
cd hydra/demo
docker compose pull
```

:::info Shortcut
For convenience, we also provide a script `./run-docker.sh`, which combines all following steps. It also performs a few sanity checks to avoid tripping ourselves.
:::

## Set up the devnet

Next, prepare the devnet configuration to bootstrap a local Cardano blockchain. 
**Note** we use a simple variant of Cardano that requires no stake pools whatsoever.

```shell
./prepare-devnet.sh
```

Bring the Cardano node up with:

```shell
docker compose up -d cardano-node
```

Verify that the devnet is up-and-running by checking the logs with:
```shell
docker compose logs cardano-node -f
```

You should see traces containing `TraceAdoptedBlock`, which means that the devnet is producing blocks .. nice!

:::info
Do not wait too long between these two commands. If you get `TraceNoLedgerView` errors from the Cardano node, the genesis start time is too far in the past, and you need to update them by running `prepare-devnet.sh` again.
:::

Next, we need to give Alice, Bob, and Carol some UTXOs to commit and some ADA to pay fees. We include a script, `seed-devnet.sh`, that uses the `cardano-cli` in the already running `cardano-node` container to do that:

```shell
./seed-devnet.sh
```

## Start Hydra nodes

Finally, now that the on-chain preparations are done, we can bring the Hydra network (all three nodes for Alice, Bob, and Carol) up by running:

```shell
docker compose up -d hydra-node-{1,2,3}
```

Using compose, you can start the demo Terminal-based User Interface (a.k.a. `hydra-tui`) to interact with Hydra nodes. There are 3 preconfigured TUI services in the Compose definition: `hydra-tui-1`, `hydra-tui-2`, and `hydra-tui-3`. To connect to the first Hydra node in a terminal, run the following command:

```shell
docker compose run hydra-tui-1
```

This will start a full-blown terminal interface loaded with signing keys corresponding to the first Hydra node. In other terminals, you can start other nodes in a similar fashion targeting `hydra-tui-2` and `hydra-tui-3` services.

## Use the head

Using the terminal interface of any node, you can now `[i]nit` the Hydra head and `[c]ommit` pre-distributed funds to it. Note that these steps are near-instant as the devnet is producing blocks much faster than a public testnet or the mainnet. After committing from all nodes, the head will automatically open, and you can also use the `hydra-tui` or the API to create new transactions and submit them to the Hydra head.

![](./open-head.png)
