import React, { useEffect, useState } from 'react';

function App() {
  const [message, setMessage] = useState('Loading...');

  useEffect(() => {
    fetch('/api/hello')
      .then((res) => res.json())
      .then((data) => setMessage(data.message))
      .catch((err) => setMessage('Error connecting to backend'));
  }, []);

  getOrigin()

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h1>React + Node.js on AWS EC2</h1>
      <p>Backend response: <strong>{message}</strong></p>
    </div>
  );
}

export default App;

