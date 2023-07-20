const { MerkleTree } = require("merkletreejs");
const { keccak256 } = require("web3-utils");
const ethers = require('ethers');

var fs = require("fs");
var path = require("path");
const WALLET_FILE_PATH = "./data/wallets.dat";
const MERKLE_TREE_FILE_PATH = "./data/merkletree.dat"

const wallets = fs
    .readFileSync(WALLET_FILE_PATH, "utf8")
    .split("\n");

const leaves = wallets.map(wallet =>
    ethers.utils.keccak256(wallet.replace("\r", ""))
);
console.log(leaves);
const tree = new MerkleTree(leaves, ethers.utils.keccak256, { sortPairs: true });
const root = tree.getHexRoot();
const rootHash = tree.getRoot().toString('hex');
console.log(root);
console.log(rootHash);

let data = "";

for (let i = 0; i < leaves.length; i++) {
    const leaf = leaves[i];

    const proof = tree.getHexProof(leaf);
    console.log("leaf = ", leaf);

    data += "Wallet Address : " + wallets[i] + "\n";
    data += "Proof : " + proof + "\n";
    data += "Verify result : " + tree.verify(proof, leaf, root) + "\n\n";
}

writeToFile(MERKLE_TREE_FILE_PATH, "Root = " + root + "\n\n" + data, (err) => {
    if (err) {
        console.error('There was an error writing the file.', err);
    } else {
        console.log('File has been written successfully.');
    }
});


function writeToFile(filePath, data, callback) {
    fs.appendFile(filePath, data, (err) => {
        if (err) {
            callback(err);
        } else {
            callback(null);
        }
    });
}



