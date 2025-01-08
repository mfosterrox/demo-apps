import React, { useEffect, useState } from "react";
import { Line } from "react-chartjs-2";

function App() {
  const [sensorData, setSensorData] = useState({ temperature: [], humidity: [] });
  const [labels, setLabels] = useState([]);
  const ws = React.useRef(null);

  useEffect(() => {
    // Connect to WebSocket
    ws.current = new WebSocket("ws://localhost:8000/ws/sensor");
    ws.current.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setSensorData((prev) => ({
        temperature: [...prev.temperature, data.temperature].slice(-10),
        humidity: [...prev.humidity, data.humidity].slice(-10),
      }));
      setLabels((prev) => [...prev, new Date().toLocaleTimeString()].slice(-10));
    };

    return () => ws.current.close();
  }, []);

  const data = {
    labels: labels,
    datasets: [
      {
        label: "Temperature (°C)",
        data: sensorData.temperature,
        borderColor: "rgba(255, 99, 132, 1)",
        backgroundColor: "rgba(255, 99, 132, 0.2)",
      },
      {
        label: "Humidity (%)",
        data: sensorData.humidity,
        borderColor: "rgba(54, 162, 235, 1)",
        backgroundColor: "rgba(54, 162, 235, 0.2)",
      },
    ],
  };

  return (
    <div style={{ width: "80%", margin: "0 auto", textAlign: "center" }}>
      <h1>Real-Time IoT Sensor Dashboard</h1>
      <Line data={data} />
    </div>
  );
}

export default App;
