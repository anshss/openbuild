const mumbaiAddress = `0x773714BBCD21d904Ad0351B7f9347206C934a47c`

export const registryAddress = mumbaiAddress

export const registryAbi = `
[
	{
		"inputs": [],
		"name": "characterId",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "characterToGenerations",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "generationId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "characterId",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "isPosted",
				"type": "bool"
			},
			{
				"internalType": "string",
				"name": "streamId",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_uri",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_characterName",
				"type": "string"
			}
		],
		"name": "createCharacter",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_characterId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_streamId",
				"type": "string"
			}
		],
		"name": "createGeneration",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "fetchAllCharacters",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "characterId",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "characterName",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "uri",
						"type": "string"
					},
					{
						"internalType": "bool",
						"name": "isSale",
						"type": "bool"
					},
					{
						"internalType": "uint256",
						"name": "_price",
						"type": "uint256"
					}
				],
				"internalType": "struct GenHub.Character[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_characterId",
				"type": "uint256"
			}
		],
		"name": "fetchAllGenerations",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "generationId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "characterId",
						"type": "uint256"
					},
					{
						"internalType": "bool",
						"name": "isPosted",
						"type": "bool"
					},
					{
						"internalType": "string",
						"name": "streamId",
						"type": "string"
					}
				],
				"internalType": "struct GenHub.Generation[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_characterId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "fetchCharacterURI",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "characterId",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "characterName",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "uri",
						"type": "string"
					},
					{
						"internalType": "bool",
						"name": "isSale",
						"type": "bool"
					},
					{
						"internalType": "uint256",
						"name": "_price",
						"type": "uint256"
					}
				],
				"internalType": "struct GenHub.Character",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_characterId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_generationId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_streamId",
				"type": "string"
			}
		],
		"name": "publishGeneration",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "userToCharacters",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "characterId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "characterName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "uri",
				"type": "string"
			},
			{
				"internalType": "bool",
				"name": "isSale",
				"type": "bool"
			},
			{
				"internalType": "uint256",
				"name": "_price",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
`