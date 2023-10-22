import Head from "next/head";
import Image from "next/image";
import styles from "@/styles/Home.module.css";
import { useState } from "react";

export default function Home() {
    const [isNetworkSwitchHighlighted, setIsNetworkSwitchHighlighted] =
        useState(false);
    const [isConnectHighlighted, setIsConnectHighlighted] = useState(false);

    const closeAll = () => {
        setIsNetworkSwitchHighlighted(false);
        setIsConnectHighlighted(false);
    };
    return (
        <>
            <main className={styles.main}>
                <div className={styles.wrapper}>
                    <div className={styles.container}>
                        <section className={styles.content}>
                            <h1 className={styles.heading1}>Protect Your Project Announcements from Scammers</h1>

                            <p className={styles.paragraph}>
                                Scammers often target project announcements to mislead and exploit innocent individuals. This not only leads to financial loss for the victims but also severely damages the reputation of the projects involved.
                            </p>
                            <div className={styles.imageContainer}>
                                <Image src="/AnnounceGuardEarth.png" alt="Announce Guard Earth graphic" width={256} height={256} />
                            </div>
                            <h2 className={styles.heading2}>The Problem</h2>
                            <p className={styles.paragraph}>
                                When scammers manipulate project announcements, they create false narratives that can lead to widespread misinformation. The end result is often financial loss for individuals who fall for these scams, and a loss of trust in the projects being impersonated.
                            </p>
                            <h2 className={styles.heading2}>Our Solution</h2>
                            <p className={styles.paragraph}>
                                With our blockchain-based solution, we provide a secure platform for project announcements. By utilizing multi-signature protection levels, we ensure that only authorized individuals can make official announcements, thereby significantly reducing the risk of scams.
                            </p>
                        </section>
                    </div>
                </div>
            </main>
        </>
    );
}
