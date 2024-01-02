import { Route, Routes } from "react-router";
import Home from "./components/home/Home";

export default function AppRouter() {
    <Routes>
        <Route path="/" element={ <Home />}/>
        {/* <Route path="/top" element={ <Top />}/>
        <Route path="/about" element={ <About />}/>
        <Route path="/contact" element={ <Contact />}/>
        <Route path="*" element={ <Notfound />}/> */}
    </Routes>
    
}