export const CHAIN_ID = 84531; // for Base Goerli chain

export const CONTRACT_ADDRESS = "0xE8ab176402c968bfBcaCB0269593AE12F4E77b33";

export const BLOCK_EXPLORER_URL = "https://goerli.basescan.org/";

export const BLOCK_EXPLORER_API_URL = "https://api-goerli.basescan.org/";

export const CONTRACT_METADATA = {
  compiler: {
    version: "0.8.22+commit.4fc1097e",
  },
  language: "Solidity",
  output: {
    abi: [
      {
        anonymous: false,
        inputs: [
          {
            indexed: true,
            internalType: "string",
            name: "_name",
            type: "string",
          },
          {
            indexed: true,
            internalType: "address",
            name: "_creator",
            type: "address",
          },
          {
            indexed: true,
            internalType: "bytes32",
            name: "_hash",
            type: "bytes32",
          },
        ],
        name: "ItemCreated",
        type: "event",
      },
      {
        inputs: [
          {
            internalType: "string",
            name: "_name",
            type: "string",
          },
          {
            internalType: "string",
            name: "_description",
            type: "string",
          },
          {
            internalType: "uint8[]",
            name: "_inputBytes",
            type: "uint8[]",
          },
        ],
        name: "createItem",
        outputs: [
          {
            internalType: "bytes32",
            name: "itemHash",
            type: "bytes32",
          },
          {
            internalType: "bool",
            name: "itemCreated",
            type: "bool",
          },
        ],
        stateMutability: "nonpayable",
        type: "function",
      },
      {
        inputs: [],
        name: "getAllCreators",
        outputs: [
          {
            internalType: "address[]",
            name: "",
            type: "address[]",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [],
        name: "getAllHashes",
        outputs: [
          {
            internalType: "bytes32[]",
            name: "",
            type: "bytes32[]",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [
          {
            internalType: "address",
            name: "_address",
            type: "address",
          },
        ],
        name: "getHashListByAddress",
        outputs: [
          {
            internalType: "bytes32[]",
            name: "",
            type: "bytes32[]",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [
          {
            internalType: "bytes32",
            name: "_hash",
            type: "bytes32",
          },
        ],
        name: "getItemByHash",
        outputs: [
          {
            components: [
              {
                internalType: "string",
                name: "name",
                type: "string",
              },
              {
                internalType: "string",
                name: "description",
                type: "string",
              },
              {
                internalType: "uint256",
                name: "blockCreated",
                type: "uint256",
              },
              {
                internalType: "address",
                name: "creator",
                type: "address",
              },
              {
                internalType: "bytes32",
                name: "hash",
                type: "bytes32",
              },
            ],
            internalType: "struct Publisher.Item",
            name: "",
            type: "tuple",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [
          {
            internalType: "address",
            name: "_creatorAddress",
            type: "address",
          },
        ],
        name: "getItemsByCreator",
        outputs: [
          {
            components: [
              {
                internalType: "string",
                name: "name",
                type: "string",
              },
              {
                internalType: "string",
                name: "description",
                type: "string",
              },
              {
                internalType: "uint256",
                name: "blockCreated",
                type: "uint256",
              },
              {
                internalType: "address",
                name: "creator",
                type: "address",
              },
              {
                internalType: "bytes32",
                name: "hash",
                type: "bytes32",
              },
            ],
            internalType: "struct Publisher.Item[]",
            name: "",
            type: "tuple[]",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [
          {
            internalType: "bytes32",
            name: "",
            type: "bytes32",
          },
        ],
        name: "hashInfo",
        outputs: [
          {
            internalType: "string",
            name: "name",
            type: "string",
          },
          {
            internalType: "string",
            name: "description",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "blockCreated",
            type: "uint256",
          },
          {
            internalType: "address",
            name: "creator",
            type: "address",
          },
          {
            internalType: "bytes32",
            name: "hash",
            type: "bytes32",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [
          {
            internalType: "address",
            name: "",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "",
            type: "uint256",
          },
        ],
        name: "hashListByCreator",
        outputs: [
          {
            internalType: "bytes32",
            name: "",
            type: "bytes32",
          },
        ],
        stateMutability: "view",
        type: "function",
      },
      {
        inputs: [],
        name: "testHash",
        outputs: [
          {
            internalType: "bytes32",
            name: "",
            type: "bytes32",
          },
        ],
        stateMutability: "pure",
        type: "function",
      },
      {
        inputs: [
          {
            internalType: "bytes",
            name: "_input",
            type: "bytes",
          },
        ],
        name: "testHash2",
        outputs: [
          {
            internalType: "bytes32",
            name: "",
            type: "bytes32",
          },
        ],
        stateMutability: "pure",
        type: "function",
      },
    ],
    devdoc: {
      kind: "dev",
      methods: {},
      version: 1,
    },
    userdoc: {
      kind: "user",
      methods: {},
      version: 1,
    },
  },
  settings: {
    compilationTarget: {
      "contracts/publisher.sol": "Publisher",
    },
    evmVersion: "shanghai",
    libraries: {},
    metadata: {
      bytecodeHash: "ipfs",
    },
    optimizer: {
      enabled: false,
      runs: 200,
    },
    remappings: [],
  },
  sources: {
    "contracts/publisher.sol": {
      keccak256:
        "0xa8a35a62a4dba872f721579a96184c98837f5e292cb229eebb7e1ce4d93657a6",
      license: "UNLICENSED",
      urls: [
        "bzz-raw://67c2114cc34e2cb7bd4cfd4381ee73254c5ea246c4d5ed4decf1057905d75e4a",
        "dweb:/ipfs/QmNbHGkp2fcwBnGomupYJD3EcuyKzkaPUf7qyByaUbfLLw",
      ],
    },
    "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/structs/EnumerableSet.sol":
      {
        keccak256:
          "0x86c1470cbfd878491e5de030072b647352d36bd27122cffb928970b1945282aa",
        license: "MIT",
        urls: [
          "bzz-raw://ad85dd393ee0a1917c57046abc5155f51f77844b2c6a42c05c1b8dd26d6ff3c1",
          "dweb:/ipfs/QmNqYc8To2NdnpP6E1tGz7t6A7beuENde5yovwov5pW1fA",
        ],
      },
  },
  version: 1,
};
