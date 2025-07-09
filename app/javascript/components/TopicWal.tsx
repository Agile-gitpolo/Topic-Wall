// import React, { useState } from 'react';
// import '../index.css';

// // mock topics
// const topics = Array.from({ length: 16 }).map((_, i) => ({
//     id: i + 1,
//     title: `话题 ${i + 1}`,
//     description: `这是第 ${i + 1} 个话题的描述内容。`,
// }));

// const gradientBorder =
//     'bg-gradient-to-tr from-pink-500 via-yellow-400 via-green-400 via-blue-500 to-purple-500';

// const floatUp =
//     'animate-[floatUp_3s_ease-in-out_infinite]';
// const floatDown =
//     'animate-[floatDown_3s_ease-in-out_infinite]';

// const floatKeyframes = `
// @keyframes floatUp {
//   0%, 100% { transform: translateY(0); }
//   50% { transform: translateY(-16px); }
// }
// @keyframes floatDown {
//   0%, 100% { transform: translateY(0); }
//   50% { transform: translateY(16px); }
// }
// `;

// const TopicWall: React.FC = () => {
//     const [search, setSearch] = useState('');
//     const filtered = topics.filter(
//         t => t.title.includes(search) || t.description.includes(search)
//     );

//     return (
//         <div className="w-full min-h-screen bg-gray-50 flex flex-col items-center px-2 py-8 fade-in">
//             {/* 动画搜索栏 */}
//             <style>{floatKeyframes}</style>
//             <div className="w-full max-w-3xl mb-8">
//                 <input
//                     type="text"
//                     value={search}
//                     onChange={e => setSearch(e.target.value)}
//                     placeholder="搜索话题..."
//                     className="w-full px-6 py-4 rounded-full border-none shadow-lg text-lg focus:ring-2 focus:ring-blue-400 transition-all duration-300 outline-none bg-white animate-pulse"
//                 />
//             </div>
//             {/* 4列响应式masonry卡片墙 */}
//             <div className="w-full max-w-6xl grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
//                 {filtered.map((topic, idx) => {
//                     // 计算列号
//                     const col = idx % 4;
//                     // 浮动动画
//                     const floatAnim = col === 0 || col === 2 ? floatUp : floatDown;
//                     // 波浪延迟
//                     const delay = `animation-delay-${(idx % 4) * 200}`;
//                     return (
//                         <div
//                             key={topic.id}
//                             className={`relative group ${floatAnim} ${delay} fade-in-card`}
//                             style={{ animationDelay: `${(idx % 4) * 0.3}s` }}
//                         >
//                             <div className={`p-[2px] rounded-2xl ${gradientBorder} transition-transform duration-300 group-hover:scale-105 group-hover:shadow-2xl`}>
//                                 <div className="bg-white rounded-2xl p-6 h-full flex flex-col">
//                                     <h3 className="text-xl font-bold mb-2 text-gray-800">{topic.title}</h3>
//                                     <p className="text-gray-500">{topic.description}</p>
//                                 </div>
//                             </div>
//                         </div>
//                     );
//                 })}
//             </div>
//             {/* 渐入动画样式 */}
//             <style>{`
//         .fade-in {
//           animation: fadeIn 1s ease;
//         }
//         .fade-in-card {
//           animation: fadeInCard 0.8s cubic-bezier(.4,0,.2,1);
//         }
//         @keyframes fadeIn {
//           from { opacity: 0; transform: translateY(32px); }
//           to { opacity: 1; transform: none; }
//         }
//         @keyframes fadeInCard {
//           from { opacity: 0; transform: scale(0.95); }
//           to { opacity: 1; transform: scale(1); }
//         }
//       `}</style>
//         </div>
//     );
// };

// export default TopicWall; 