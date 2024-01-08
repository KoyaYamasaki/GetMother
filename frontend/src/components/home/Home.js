import { Center, Text, VStack, Button } from "@chakra-ui/react";
import { useState } from "react";
import Modal from "../modal/Modal";

export default function Home () {
    
    const [showModal, setShowModal] = useState(false);
    
    const onShowModal = () => {
        setShowModal(true);
    };


    return (
        <Center
            h="100vh"
            style={{backgroundImage: `url("/assets/imgs/top.jpg")` }}>
                <VStack>
                    <Text 
                        fontWeight="bold"
                        fontSize={{ base: "lg", md: "3xl", lg: "3xl" }}>
                            母なる自然（お母さん）にようこそ
                    </Text>
                    <Text
                        margin={"60px"}
                        textAlign={"start"}
                        fontSize={"15px"}>
                            "nature"という言葉は、生まれや性格を意味するラテン語の"natura"に由来する。<br/>
                            英語では、「世界の現象全体」という意味で1266年に初めて使われたことが記録されている。<br/>
                            中世には、"natura"と母なる自然の擬人化が広く普及していた。<br/>
                            神と人間の間に位置する概念としては、古代ギリシャにまで遡ることができるが、<br/>
                            地球（古英語で"Eorthe"）が女神として擬人化されていた可能性もある。<br/>
                            ギリシャでは、世界の現象全体を抽象化して自然を「発明」し、アリストテレスが継承した。<br/>
                            中世のキリスト教の思想家たちは、自然は神によって創造されたものであり、<br/>
                            その居場所は不変の天国と月の下にある地上にあると考えていた。<br/>
                            自然は中央に位置し、その上には天使、下には悪魔や地獄が存在する。<br/>
                            中世の人々にとって、「母なる自然」は女神ではなく、あくまでも擬人化された存在だった。<br/>
                        <a href="https://ja.wikipedia.org/wiki/%E6%AF%8D%E3%81%AA%E3%82%8B%E8%87%AA%E7%84%B6">出典：「母なる自然」(wikipediaより)</a>
                    </Text>
                    <Button
                        fontWeight="bold"
                        paddingStart="45px"
                        paddingEnd="45px"
                        onClick={onShowModal}>
                            お母さんいいですか？
                    </Button>
                    <Modal 
                        showFlag={showModal}
                        setShowModal={setShowModal}
                        url={"http://localhost:8000/randommother"}
                        contentMessage="お母さんは許可します。あなたは許されたのです"
                        button={"ありがとうございます"}/>
                </VStack>
      </Center>
    );
}
