import React from "react";
import Link from "next/link";
import { loginDataverse } from "@/utils";

export default function NavBar() {
    return (
        <nav className="fixed h-[75px] top-0 z-50 w-full bg-white border-b border-gray-200 dark:bg-gray-800 dark:border-gray-700">
            <div className="px-3 py-3 lg:px-5 lg:pl-3">
                <div className="flex items-center justify-between">
                    <div className="flex items-center justify-start">
                        <h2>GenHub</h2>
                    </div>
                    <div className="flex items-center">
                        <div className="flex items-center ml-3">
                            {/* <button onClick={loginDataverse}>dataverse</button> */}
                        </div>
                    </div>
                </div>
            </div>
        </nav>
    );
}
