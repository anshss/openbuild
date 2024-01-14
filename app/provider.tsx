"use client";

import * as React from "react";
import { sepolia, mainnet } from "@starknet-react/chains";
import {
  StarknetConfig,
  publicProvider,
  argent,
  braavos,
  useInjectedConnectors,
  voyager
} from "@starknet-react/core";


export function StarknetProvider({ children }: { children: React.ReactNode }) {
    const [mounted, setMounted] = React.useState(false);
    React.useEffect(() => setMounted(true), []);
    const { connectors } = useInjectedConnectors({
      recommended: [
        argent(),
        braavos(),
      ],
      includeRecommended: "onlyIfNoConnectors",
      order: "random"
    });
  
    return (
      <StarknetConfig
        chains={[sepolia]}
        provider={publicProvider()}
        connectors={connectors}
        explorer={voyager}
      >
        { mounted && children}
      </StarknetConfig>
    );
  }
