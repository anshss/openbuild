import { React, useEffect, useState } from "react";;
import styled from 'styled-components';
import { useAccount, useConnect, useDisconnect, useBalance } from "@starknet-react/core";

export default function NavBar() {

    const { address, isConnected } = useAccount();
    const { connect, connectors } = useConnect();
    const { disconnect } = useDisconnect();
    const { data } = useBalance({
        address,
        watch: true
    })
    return (
        <nav className="fixed h-[75px] top-0 z-50 w-full bg-white border-b border-gray-200 dark:bg-gray-800 dark:border-gray-700">
            <div className="px-3 py-3 lg:px-5 lg:pl-3">
                <div className="flex items-center justify-between">
                    <div className="flex items-center justify-start">
                        <h2>OpenGen</h2>
                    </div>
                    <div>{address}</div>
                    {isConnected && <div>{data?.formatted} ETH</div>}
                    <div className="flex items-center">
                        {!isConnected &&
                            <ConnectionContainer>
                                <ul>
                                    {connectors.map((connector) => (
                                        <li key={connector.id}>
                                            <button onClick={() => connect({ connector })}>
                                                Connect
                                            </button>
                                        </li>
                                    ))}
                                </ul>
                            </ConnectionContainer>

                        }
                        {isConnected &&
                            <DisconnectContainer >
                                <div onClick={() => disconnect()}>Disconnect</div>
                            </DisconnectContainer>
                        }

                    </div>
                </div>
            </div>
        </nav>
    );
}

const ConnectionContainer = styled.div`
    height: 3rem;
    width: 10rem;
    background-color: blue;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    color: white;
    border-radius: 0.5rem;
    transition: opacity 0.15s;
    margin-right: 2rem;

    &:hover {
      opacity: 0.8;
    }

    &:active {
      opacity: 0.7;
    }
`
const DisconnectContainer = styled.div`
    height: 3rem;
    width: 10rem;
    background-color: blue;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    color: white;
    border-radius: 0.5rem;
    transition: opacity 0.15s;

    &:hover {
      opacity: 0.8;
    }

    &:active {
      opacity: 0.7;
    }
`
