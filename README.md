


## Lottery Smart Contract

This smart contract is designed to implement a lottery system where users can participate by depositing ETH. The lottery consists of two periods: the DEPOSIT period and the BREAK period. During the DEPOSIT period, users can join the lottery by paying ETH, while in the BREAK period, no new participants are allowed. At the end of each DEPOSIT period, N random winners are determined, and they can claim their winnings. Users who are not winners cannot withdraw their deposits unless they are whitelisted or have rented Ticket NFTs.

#### Requirements
+ Node.js
+ Foundry
+ Forge

#### Installation


1. Install Repository.
```shell
git clone https://github.com/0x00dev/Lottery.git
```

2. Install dependencies.
```shell
forge install
```

3. Compile the contract.
```shell
forge build
```

4. Generate the merkle tree using the provided script:
```shell
cd test/scripts
npm install
node test/scripts/merkle_tree.js
```

5. Test smart contract.
```shell
forge test --fork-url <FORK_URL> -vvv --fork-block-number <BLOCK_NUMBER>
```

6. Deploy the smart contract to your desired Ethereum network using Forge or Hardhat or any other deployment tool of your choice.
```shell
forge script script/Lottery.s.sol --rpc-url <RPC_URL> --chain-id 80001 --etherscan-api-key <ETHER_SCAN_API_KEY> --broadcast --verify -vvvv --legacy                 
```

7. Create and deploy the subgraph to fetch the list of winners. Refer to the documentation of the subgraph framework you are using for detailed instructions.

- Proxy
https://mumbai.polygonscan.com/address/0xCCF6a20fd003C44cB48c3cF6A211659262d70F23

- Lottery
https://mumbai.polygonscan.com/address/0x51dc3395a4f1985Ca9dd622e6627096726a859E5

- Subgraph
https://thegraph.com/hosted-service/subgraph/0x00dev/lottery

#### Usage

Once the smart contract is deployed and the merkle tree is generated, users can interact with the lottery system using an Ethereum wallet or DApp.

##### Joining the Lottery:

During the DEPOSIT period, users can join the lottery by sending a deposit of ETH to the smart contract.
Whitelisted users can participate for free.

##### Renting Ticket NFTs:

Users who own Ticket NFTs can rent them to other users in exchange for a fixed amount of ETH.
This action mints a new Wrapped NFT for the borrower.

##### Claiming Rewards:

If a Ticket NFT is selected as a winner, the borrower should pay a certain percentage of the reward to the Ticket NFT owner as a fee.
The borrower can claim the remaining amount to their address.
Once claimed, the Wrapped NFT is burnt.

##### Handling Pending Rewards:

If the pending rewards for a Wrapped NFT are not used to claim during the BREAK period, lenders can burn the Wrapped NFT and claim the entire pending reward.

#### License

This project is licensed under the [MIT License](https://opensource.org/license/mit/ "MIT License link")
