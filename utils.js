"use client";
import web3modal from "web3modal";
import { ethers } from "ethers";
import { registryAddress, registryAbi } from "./config";
import axios from "axios";
import { Web3Storage } from "web3.storage";
import {
    DataverseConnector,
    SYSTEM_CALL,
    RESOURCE,
} from "@dataverse/dataverse-connector";
import { timeStamp } from "console";

let allCharacters = [];
let generations = [];

fetchAllCharacters();


// --------- Contract Instance

export async function getRegistryContract(providerOrSigner) {
    const modal = new web3modal();
    const connection = await modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const contract = new ethers.Contract(
        registryAddress,
        registryAbi,
        provider
    );
    if (providerOrSigner == true) {
        const signer = provider.getSigner();
        const contract = new ethers.Contract(
            registryAddress,
            registryAbi,
            signer
        );
        return contract;
    }
    return contract;
}

export async function getUserAddress() {
    const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
    });
    return accounts[0];
}

// --------- APIs

export async function callCharacterGenAPI(_prompt) {
    // const apiUrl = "http://127.0.0.1:3000/generate-model-img/";
    const apiUrl = "https://generations-zvglklnxya-em.a.run.app/character"
    try {
        const payload = {
            mod_description: _prompt,
        };

        console.log("payload", payload);

        console.log("requested")
        const response = await axios.post(apiUrl, payload);
        console.log("fallback")
        
        console.log(response.data.s3_public_url);
        return response.data.s3_public_url;
    } catch (error) {
        console.error("consoling character gen error", error);
        return null; 
    }
}

export async function callImageGenAPI(_prompt, _productImage, _id, _name) {
    // const _modelImage = await getCharacterURIFromId(_id);
    const streamId = allCharacters[_id - 1].uri;
    const _modelImage = await loadWithDataverse(streamId);

    console.log("model image", _modelImage);

    const apiUrl = "https://generations-zvglklnxya-em.a.run.app/image";
    try {
        const payload = {
            ad_product_name: _name,
            ad_product_description: _prompt,
            image_url1: _modelImage,
            image_url2: _productImage,
        };

        console.log("payload", payload);

        const response = await axios.post(apiUrl, payload);
        console.log("response", response);
        return response.data.s3_public_url;
    } catch (error) {
        console.error("consoling image gen error", error);
        return null;
    }
}

export async function callVideoGenAPI(_productName, _prompt, _id, _gender) {

    const streamId = allCharacters[_id - 1].uri;
    const _modelImage = await loadWithDataverse(streamId);

    const apiUrl = "https://generations-zvglklnxya-em.a.run.app/video";
    try {
        const payload = {
            model_image: _modelImage,
            product_name: _productName,
            product_description: _prompt,
            model_gender: _gender,
        };

        console.log("payload", payload);

        const response = await axios.post(apiUrl, payload);
        console.log(response);
        return response.data.result;
    } catch (error) {
        console.error("consoling video gen error", error);
        return null;
    }
}

export async function callFineTuneAPI(_generatedImage, _prompt) {
    const apiUrl = "https://generations-zvglklnxya-em.a.run.app/finetune";
    try {
        const payload = {
            image_url: _generatedImage,
            user_prompt: _prompt,
        };

        console.log("payload", payload);

        const response = await axios.post(apiUrl, payload);
        console.log("res1", response);
        return response.data.s3_public_url[0];
    } catch (error) {
        console.error("consoling fine tune gen error", error);
        return null;
    }
}

// --------- IPFS

async function createModelURI(_name, _prompt, image) {
    // if (!_name || !_prompt || !image) return;
    console.log("img:", image);
    const data = JSON.stringify({ _name, _prompt, image });
    const files = [new File([data], "data.json")];
    const metaCID = await uploadToIPFS(files);
    const url = `https://ipfs.io/ipfs/${metaCID}/data.json`;
    console.log(url);
    return url;
}

async function createContentURI(_productImage, _prompt, image, tba) {
    // if (!_productImage || !_prompt || !image) return;
    const _modelId = await getModelIdByTBA(tba);
    const data = JSON.stringify({ _productImage, _prompt, image, _modelId });
    const files = [new File([data], "data.json")];
    const metaCID = await uploadToIPFS(files);
    const url = `https://ipfs.io/ipfs/${metaCID}/data.json`;
    console.log(url);
    return url;
}

// --------- Dataverse

const dataverseConnector = new DataverseConnector();

export async function loginDataverse() {
    await dataverseConnector.connectWallet();
    const pkh = await dataverseConnector.runOS({
        method: SYSTEM_CALL.createCapability,
        params: {
            appId: "4e6d651a-77ea-441d-9198-a3edf968e9f4",
            resource: RESOURCE.CERAMIC,
        },
    });
    console.log("pkh:", pkh);
    return pkh;
}

export async function uploadToDataverse(inputText) {
    await loginDataverse();

    const encrypted = JSON.stringify({
        text: false,
        images: false,
        videos: false,
    });

    await dataverseConnector.connectWallet();
    const res = await dataverseConnector.runOS({
        method: SYSTEM_CALL.createIndexFile,
        params: {
            modelId:
                "kjzl6hvfrbw6c8eukmrwgbdmhdy2h7vw4l0ypd2yfkli7xfo1qt6ogp3srr376v",
            fileName: "test",
            fileContent: {
                modelVersion: "0",
                text: inputText,
                images: [],
                videos: [],
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
                encrypted,
            },
        },
    });

    console.log(res);
    console.log(res.fileContent.file.contentId);

    return res.fileContent.file.contentId;
}

export const loadWithDataverse = async (streamId) => {
    await loginDataverse();

    const res = await dataverseConnector.runOS({
        method: SYSTEM_CALL.loadFile,
        params: streamId,
    });

    return res.fileContent.content.text;
};

// --------- Contract Calls

export async function createCharacterCall(_uri, _characterName) {
    const contract = await getRegistryContract(true);
    const tx = await contract.createCharacter(_uri, _characterName);
    await tx.wait();
    console.log("Character created");
}

export async function createGenerationCall(_characterId, _streamId) {
    const contract = await getRegistryContract(true);
    const tx = await contract.createGeneration(_characterId, _streamId);
    await tx.wait();
    console.log("Character created");
}

export async function publishGenerationCall(
    _characterId,
    _generationId,
    _ipfsLink
) {
    const contract = await getRegistryContract(true);
    const tx = await contract.publishGeneration(
        _characterId,
        _generationId,
        _ipfsLink
    );
    await tx.wait();
    await fetchAllCharacters()
    console.log("Character created");
}

// --------- Contract Fetching

export async function getCharacterURIFromId(_characterId) {
    const user = await getUserAddress();
    const contract = await getRegistryContract();
    console.log(_characterId, user)
    const data = await contract.fetchCharacterURI(_characterId, user);
    return data;
}

export async function fetchAllCharacters() {
    if (allCharacters.length > 0) return allCharacters;

    const user = await getUserAddress();
    const contract = await getRegistryContract();

    const data = await contract.fetchAllCharacters(user);
    // console.log("data", data)
    const items = await Promise.all(
        data.map(async (i) => {
            let item = {
                characterId: i.characterId.toNumber(),
                characterName: i.characterName.toString(),
                uri: i.uri.toString(),
                isSale: i.isSale.toString(),
                _price: i._price.toNumber(),
            };
            return item;
        })
    );

    allCharacters = items;
    console.log("All Characters", items);
    return items;
}

export async function fetchAllGenerations() {
    if (generations.length > 0) return generations;

    const contract = await getRegistryContract();
    const charactersArray = await fetchAllCharacters()

    generations = await gensArr(charactersArray)
  
    async function gensArr(arr) {
        let gens = [];
        await Promise.all(arr.map(async (character) => {
            const generationByCharacter = await contract.fetchAllGenerations(
                character.characterId
                );

            const subItems = await Promise.all(
                generationByCharacter.map(async (i) => {
                    let item = {
                        generationId: i.generationId.toNumber(),
                        characterId: i.characterId.toNumber(),
                        isPosted: i.isPosted.toString(),
                        streamId: i.streamId.toString(),
                    };
                    return item;
                    
                })

            )
            gens.push(...subItems);
        }))
        return gens
    }

    console.log("Generations: ", generations);
    return generations;
}

export async function fetchPosts() {
    // console.log("1", generations);
    if (generations.length > 0) {
        const filteredArray = generations.filter(
            (subarray) => subarray.isPosted == "true"
        );
        // console.log("2", filteredArray);
        return filteredArray;
    } else {
        const data = await fetchAllGenerations();
        // console.log("3", data);
        const filteredArray = data.filter(
            (subarray) => subarray.isPosted == "true"
        );
        return filteredArray;
    }
}

// --------- IPFS Instance

function getAccessToken() {
    // return process.env.NEXT_PUBLIC_Web3StorageID
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDkyMjkyQjQ5YzFjN2ExMzhERWQxQzQ3NGNlNmEyNmM1NURFNWQ0REQiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NjUyMzg2MDc1NDEsIm5hbWUiOiJNZXRhRmkifQ.cwyjEIx8vXtTnn8Y3vctroo_rooHV4ww_2xKY-MT0rs";
}

function makeStorageClient() {
    return new Web3Storage({ token: getAccessToken() });
}

export const uploadToIPFS = async (files) => {
    const client = makeStorageClient();
    const cid = await client.put(files);
    return cid;
};

export async function getSigner() {
    const modal = new web3modal();
    const connection = await modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();
    return signer;
}
