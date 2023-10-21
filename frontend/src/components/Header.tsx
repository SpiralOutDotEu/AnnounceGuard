import Image from "next/image";
import styles from "@/styles/Home.module.css";
import { useState } from "react";

export default function Header() {
    const [isNetworkSwitchHighlighted, setIsNetworkSwitchHighlighted] = useState(false);
    const [isConnectHighlighted, setIsConnectHighlighted] = useState(false);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);  // New state for mobile menu

    const closeAll = () => {
        setIsNetworkSwitchHighlighted(false);
        setIsConnectHighlighted(false);
        setMobileMenuOpen(false);  // Close the mobile menu when an item is clicked
    };

    return (
        <header>
            <div
                className={styles.backdrop}
                style={{
                    opacity:
                        isConnectHighlighted || isNetworkSwitchHighlighted
                            ? 1
                            : 0,
                }}
            />
            <div className={styles.header}>
                <div className={styles.logo}>
                    <Image
                        src="/logo.png"
                        alt="WalletConnect Logo"
                        height="72"
                        width="72"
                    />
                    <a>AnnounceGuard</a>
                </div>
                {/* Hamburger icon */}
                <div className={styles.hamburger} onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
                    ☰
                </div>
                <div className={`${styles.buttons} ${mobileMenuOpen ? styles.mobileMenuOpen : ''}`}>
                    <div
                        onClick={closeAll}
                        className={`${styles.highlight} ${
                            isNetworkSwitchHighlighted
                                ? styles.highlightSelected
                                : ``
                        }`}
                    >
                        <w3m-network-button />
                    </div>
                    <div
                        onClick={closeAll}
                        className={`${styles.highlight} ${
                            isConnectHighlighted
                                ? styles.highlightSelected
                                : ``
                        }`}
                    >
                        <w3m-button />
                    </div>
                </div>
            </div>
        </header>
    );
}
