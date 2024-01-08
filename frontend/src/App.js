import { BrowserRouter, Route, Routes } from 'react-router-dom';
import Home from './components/home/Home';
import Login from './components/login/Login';
import NavBar from './components/menu/NavBar';

export default function App() {
  return (
    <>
    <BrowserRouter>
        <NavBar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/home" element={<Home />} />
          <Route path="/login" element={<Login />} />
        </Routes>
      </BrowserRouter>
    </>
  );
}