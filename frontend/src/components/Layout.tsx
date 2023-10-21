// components/Layout.js
import Head from "next/head";
import Header from "./Header";  // Import the Header component
import { Metadata } from 'next'
import styles from "@/styles/Home.module.css";

type Props = {  // Define a Props type
    children: React.ReactNode;
};

export const metadata: Metadata = {
    title: 'AnnounceGuard',
    description: 'A blockchain powered announcement system',
    icons: {
        icon: './favicon/favicon.ico',
        shortcut: './favicon/favicon.ico',
        apple: './favicon/apple-touch-icon.png',
      },
  }

export default function Layout({children}: Props) {
    return (
        <>
            <Head>
                <title>AnnounceGuard</title>
                <meta
                    name="description"
                    content="A blockchain powered announcement system"
                />
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1"
                />
                <link rel="icon" href="/icon.ico" />
            </Head>
            <div className={styles.headerClass}>
                <Header />
            </div>
            <main className={styles.main}>
                <div className={styles.wrapper}>
                    {children}
                </div>
            </main>
        </>
    );
}
