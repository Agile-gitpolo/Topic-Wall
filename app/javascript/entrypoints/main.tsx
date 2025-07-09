import React from "react";
import ReactDOM from "react-dom/client";
import TopicWall from "../components/TopicWal";
import "./index.css";

const root = document.getElementById("root");
if (root) {
    ReactDOM.createRoot(root).render(
        <React.StrictMode>
            <TopicWall />
        </React.StrictMode>
    );
}

console.log('vite ok')