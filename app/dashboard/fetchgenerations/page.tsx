/* eslint-disable jsx-a11y/alt-text */
/* eslint-disable @next/next/no-img-element */
"use client";

import {
    fetchAllGenerations,
    loadWithDataverse,
    publishGenerationCall,
    uploadToIPFS,
} from "@/utils";
import { useEffect, useState } from "react";
import SideBar from "@/components/SideBar";
import NavBar from "@/components/NavBar";
import axios from "axios";

const FetchModels = () => {
    const [data, setData] = useState<any>([]);

    const [loaders, setLoaders] = useState({
        publishLoader: false,
    });

    useEffect(() => {
        fetchAllGenerationsData();
    }, []);

    async function fetchAllGenerationsData() {
        const results = await fetchAllGenerations();
        setData(results);
    }

    function LinkoCard({
        generationId,
        characterId,
        isPosted,
        streamId,
    }: {
        generationId: any;
        characterId: any;
        isPosted: any;
        streamId: any;
    }) {
        const [imageLink, setImage] = useState<String | null>("");
        console.log(streamId)

        useEffect(() => {
            if (isPosted=="false") {
                fetchStreamURI();
            }
            else {
                fetchIpfsURI()
            }
        }, []);

        async function fetchStreamURI() {
            const result = await loadWithDataverse(streamId);
            setImage(result);
        }

        async function fetchIpfsURI() {
            console.log("uri hove yo")
            const res1 = await axios.get(streamId);
            console.log("res1", res1)
            setImage(res1.data.ipfsLink);
        }



        async function publish() {
            console.log("imglink", imageLink);
            const obj = {
                ipfsLink: imageLink,
            };
            const data = JSON.stringify(obj);
            const files = [new File([data], "data.json")];
            const ipfsCid = await uploadToIPFS(files);
            const url = `https://ipfs.io/ipfs/${ipfsCid}/data.json`;
            console.log(url);
            await publishGenerationCall(characterId, generationId, url);
        }

        return (
            <div className="flex justify-center mt-10 w-[100%]">
                <div className="flex w-[70%] gap-5 p-6 cursor-pointer bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700">
                    <img src={imageLink} width="300px" />
                    <div className="flex flex-col justify-between">
                        <div className="w-[100%]">
                            <p className="mb-2 text-xl font-bold tracking-tight text-gray-900 dark:text-white">
                                Character Id: {characterId}
                            </p>
                            <p className="font-normal text-gray-700 dark:text-gray-400 mt-2">
                                Posted: {isPosted}
                            </p>
                        </div>
                        <button
                            className=" text-center h-[50px] w-[140px] inline-flex justify-center items-center px-3 py-2 text-sm font-medium text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
                            onClick={publish}
                        >
                            {!loaders.publishLoader ? (
                                <span>Post</span>
                            ) : (
                                <svg
                                    aria-hidden="true"
                                    role="status"
                                    className="inline w-4 h-4 text-white animate-spin"
                                    viewBox="0 0 100 101"
                                    fill="none"
                                    xmlns="http://www.w3.org/2000/svg"
                                >
                                    <path
                                        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                                        fill="#E5E7EB"
                                    />
                                    <path
                                        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                                        fill="currentColor"
                                    />
                                </svg>
                            )}
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div>
            <NavBar />
            <div className="flex">
                <SideBar />
                <div className="p-4 sm:ml-64 pt-20 bg-gray-900 w-full min-h-screen">
                    {/* <p className="font-normal text-gray-700 dark:text-gray-400 mt-2">
                    Model Gen Address: {modelGenAddress}
                </p> */}
                    <div className="mt-10">
                        <h1 className="font-bold text-3xl text-center">
                            Create Post
                        </h1>
                    </div>
                    {data.map((item: any, i: any) => (
                        <LinkoCard
                            key={i}
                            generationId={item.generationId}
                            characterId={item.characterId}
                            isPosted={item.isPosted}
                            streamId={item.streamId}
                        />
                    ))}
                </div>
            </div>
        </div>
    );
};

export default FetchModels;
