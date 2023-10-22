import { useEffect, useState } from 'react';
import styles from "@/styles/Home.module.css";

type Channel = [string, string];  // [name, channelAddress]

function Channels() {
    const [channels, setChannels] = useState<Channel[]>([]);
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState<number>(0);

    useEffect(() => {
        async function fetchChannels() {
            const res = await fetch(`/api/channels?page=${page}`);
            const data = await res.json();
            setChannels(data.data);
            setTotalPages(data.pages);
        }
        fetchChannels();
    }, [page]);

    return (
        <>
            <main className={styles.main}>
                <div className={styles.wrapper}>
                    <div className={styles.container}>
                        <section className={styles.content}>
                            <div>
                                <h1>Channels</h1>
                                <table className={styles.table}>
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Address</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {channels.map((channel, index) => (
                                            <tr key={index}>
                                                <td>{index }</td>
                                                <td>{channel[0]}</td>
                                                <td>{channel[1]}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                                {/* Pagination */}
                                <button onClick={() => setPage(page => Math.max(page - 1, 1))} disabled={page === 1}>Previous</button>
                                <button onClick={() => setPage(page => Math.min(page + 1, totalPages))} disabled={page === totalPages}>Next</button>
                            </div>
                        </section>
                    </div>
                </div>
            </main>
        </>
    );
}

export default Channels;