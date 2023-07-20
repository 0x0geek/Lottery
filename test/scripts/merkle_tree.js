const { MerkleTree } = require("merkletreejs");;
const keccak256 = require("keccak256");
var fs = require("fs");
var path = require("path");
const WALLET_FILE_PATH = "./data/wallets.dat";
const MERKLE_TREE_FILE_PATH = "./data/merkletree.dat"

const wallets = fs
    .readFileSync(WALLET_FILE_PATH, "utf8")
    .split("\n");

const leaves = wallets.map(wallet => keccak256(wallet));
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const root = tree.getHexRoot();

let data = "";

for (let i = 0; i < leaves.length; i++) {
    const leaf = leaves[i];

    const proof = tree.getHexProof(leaf);

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



