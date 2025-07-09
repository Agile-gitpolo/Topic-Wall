// TopicWall.jsx
import React, { useState, useEffect, useRef } from 'react';
import ExploreCarousel from './ExploreCarousel';
import '../components/styles.css';

const TopicWall = () => {
    const topics = Array.from({ length: 16 }).map((_, i) => ({
        id: i + 1,
        title: `话题 ${i + 1}`,
        description: `这是第 ${i + 1} 个话题的描述内容。` + ' '.repeat(Math.floor(Math.random() * 100)),
    }));

    const insGradients = [
        'from-pink-500 via-red-500 to-yellow-400',
        'from-yellow-400 via-green-400 to-blue-500',
        'from-purple-500 via-pink-500 to-orange-400',
        'from-blue-500 via-cyan-400 to-green-400',
    ];

    const [search, setSearch] = useState('');
    const [colCount, setColCount] = useState(getColCount());
    const [explorePage, setExplorePage] = useState(0);

    function getColCount() {
        if (typeof window === 'undefined') return 1;
        if (window.innerWidth < 640) return 1;
        if (window.innerWidth < 1024) return 2;
        return 4;
    }

    useEffect(() => {
        const onResize = () => setColCount(getColCount());
        window.addEventListener('resize', onResize);
        return () => window.removeEventListener('resize', onResize);
    }, []);

    const filtered = topics.filter(
        t => t.title.includes(search) || t.description.includes(search)
    );
    const columns = Array.from({ length: colCount }, () => []);
    filtered.forEach((topic, i) => {
        columns[i % colCount].push(topic);
    });

    useEffect(() => {
        const btn = document.getElementById('theme-toggle');
        const root = document.documentElement;
        const updateIcon = () => {
            if (root.classList.contains('dark')) {
                btn.style.setProperty('--light', 0);
                btn.style.setProperty('--dark', 1);
            } else {
                btn.style.setProperty('--light', 1);
                btn.style.setProperty('--dark', 0);
            }
        };
        if (btn) {
            btn.onclick = () => {
                root.classList.toggle('dark');
                localStorage.setItem('theme', root.classList.contains('dark') ? 'dark' : 'light');
                updateIcon();
            };
            updateIcon();
        }
    }, []);

    useEffect(() => {
        const fadeEls = document.querySelectorAll('.fade-in-card');
        const io = new IntersectionObserver(entries => {
            entries.forEach(entry => {
                if (entry.isIntersecting) entry.target.classList.add('in-view');
            });
        }, { threshold: 0.15 });
        fadeEls.forEach(el => io.observe(el));
        return () => io.disconnect();
    }, [colCount, filtered.length]);

    const getImg = id => `https://images.pexels.com/photos/${1000000 + id}/pexels-photo-${1000000 + id}.jpeg?auto=compress&w=480&h=320&fit=crop`;

    return (
        <div className="relative min-h-screen w-full bg-gray-50 dark:bg-neutral-900 transition-colors duration-500">
            {/* Header */}
            <nav className="fixed top-0 left-0 w-full z-50 flex items-center justify-between px-8 py-4 bg-white/70 dark:bg-neutral-800/70 backdrop-blur-md shadow-lg">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-pink-500 via-yellow-400 to-purple-500 flex items-center justify-center shadow-md">
                        <svg width="28" height="28" viewBox="0 0 32 32" fill="none">
                            <circle cx="16" cy="16" r="14" fill="white" />
                            <circle cx="16" cy="16" r="8" fill="url(#insg)" />
                            <defs>
                                <radialGradient id="insg" cx="0" cy="0" r="1" gradientTransform="translate(16 16) scale(8)" gradientUnits="userSpaceOnUse">
                                    <stop stopColor="#f9a8d4" />
                                    <stop offset="0.5" stopColor="#fbbf24" />
                                    <stop offset="1" stopColor="#a78bfa" />
                                </radialGradient>
                            </defs>
                        </svg>
                    </div>
                    <span className="text-2xl font-extrabold text-gray-800 dark:text-white tracking-tight select-none">ins话题墙</span>
                </div>
                <button id="theme-toggle" className="w-12 h-12 rounded-full flex items-center justify-center bg-gray-200 dark:bg-neutral-700 hover:bg-pink-200 dark:hover:bg-pink-400 transition-colors relative group" aria-label="切换明暗模式">
                    <span className="absolute left-2 transition-all duration-300" style={{ opacity: 'var(--light,1)' }}>
                        <svg width="28" height="28" fill="none" viewBox="0 0 24 24">
                            <path d="M12 4V2m0 20v-2m8-8h2M2 12H4m15.07 7.07l1.42 1.42M4.93 4.93L3.51 3.51m15.56 0l-1.42 1.42M4.93 19.07l-1.42 1.42" stroke="#fbbf24" strokeWidth="2" strokeLinecap="round" />
                            <circle cx="12" cy="12" r="5" fill="#fde68a" />
                        </svg>
                    </span>
                    <span className="absolute right-2 transition-all duration-300" style={{ opacity: 'var(--dark,0)' }}>
                        <svg width="28" height="28" fill="none" viewBox="0 0 24 24">
                            <path d="M21 12.79A9 9 0 1111.21 3a7 7 0 109.79 9.79z" fill="#a78bfa" />
                        </svg>
                    </span>
                </button>
            </nav>

            {/* 搜索栏 */}
            <section id="search-section" className="pt-28 pb-10 min-h-[60vh] flex flex-col items-center justify-center w-full">
                <div className="w-full flex justify-center mb-12">
                    <div className="relative w-full max-w-2xl">
                        <input
                            type="text"
                            value={search}
                            onChange={e => setSearch(e.target.value)}
                            placeholder="搜索话题..."
                            className="w-full px-8 py-5 rounded-full text-2xl font-bold bg-white/80 dark:bg-neutral-800/80 shadow-xl placeholder-gray-400 dark:placeholder-gray-500 text-gray-900 dark:text-white"
                        />
                    </div>
                </div>

                {/* 瀑布流卡片区 */}
                <div className="w-full flex justify-center">
                    <div className="flex w-full max-w-7xl gap-8 px-2">
                        {columns.map((col, colIdx) => (
                            <div key={colIdx} className="flex flex-col gap-8 flex-1 min-w-0 items-center">
                                {col.map((topic, idx) => (
                                    <div key={topic.id} className="relative group fade-in-card animate-float" style={{ animationDelay: `${idx * 0.5}s` }}>
                                        <div className={`p-[4px] rounded-3xl bg-gradient-to-tr ${insGradients[colIdx % insGradients.length]} group-hover:scale-105 group-hover:shadow-2xl`}>
                                            <div className="bg-white/90 dark:bg-neutral-800/90 rounded-2xl p-0 min-h-[320px] flex flex-col justify-between shadow-inner overflow-hidden">
                                                <img src={getImg(topic.id)} alt="topic" className="w-full h-48 object-cover rounded-t-2xl mb-0 group-hover:scale-105" loading="lazy" />
                                                <div className="p-7 flex-1 flex flex-col justify-center">
                                                    <h3 className="text-2xl font-bold mb-2 text-gray-800 dark:text-white text-center">{topic.title}</h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* 探索页 */}
            <section id="explore-section" className="min-h-screen flex flex-col items-center justify-center bg-transparent relative z-20">
                <div className="w-full flex flex-col items-center justify-center mt-8 mb-8">
                    <h2 className="text-4xl md:text-5xl font-extrabold text-gray-900 dark:text-white mb-2 tracking-tight">寻找下一个</h2>
                    <div className="text-2xl md:text-3xl font-extrabold text-yellow-600 mb-2 tracking-wide">家居装潢点子</div>
                    <div className="flex justify-center items-center mt-2">
                        <span className="w-2 h-2 rounded-full bg-yellow-400 mx-1"></span>
                        <span className="w-2 h-2 rounded-full bg-gray-300 mx-1"></span>
                        <span className="w-2 h-2 rounded-full bg-gray-300 mx-1"></span>
                        <span className="w-2 h-2 rounded-full bg-gray-300 mx-1"></span>
                    </div>
                </div>
                <ExploreCarousel />
            </section>
        </div>
    );
};

export default TopicWall;
