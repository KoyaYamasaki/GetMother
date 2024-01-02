import './App.css';
import Home from './components/home/Home';
import NavBar from './components/menu/NavBar';



export default function App() {
  return (
    <div className="App">
        <NavBar />
      <Home />
    </div>
  );
}