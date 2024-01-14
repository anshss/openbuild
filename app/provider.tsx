"use client";

import * as React from "react";
import {sepolia} from "@starknet-react/chains";
// import { InjectedConnector } from "starknetkit/injected";
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
      // Show these connectors if the user has no connector installed.
      recommended: [
        braavos(),
      ],
      // Hide recommended connectors if the user has any connector installed.
      includeRecommended: "onlyIfNoConnectors",
      // Randomize the order of the connectors.
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
