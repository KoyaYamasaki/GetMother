import { Button, Img, Text, VStack } from "@chakra-ui/react";
import React from "react";

export default function Modal(props) {

    const closeModal = () => {
        props.setShowModal(false);
    }

    return (
        <>
            {props.showFlag ? (
                <div id="overlay" style={overlay}>
                    <div id="modalContent" style={modalContent}> 
                        <VStack>
                            <Img src={`${props.url}`} alt={"/assets/imgs/acceptable_mother_1.jpg"} height="300px" width="450px"/>
                            <Text 
                                fontSize={'25px'}
                                fontWeight="bold"
                                paddingLeft={"45px"}
                                paddingRight={"45px"}>
                                    {props.contentMessage}
                            </Text>
                            <Button onClick={closeModal}>
                                {props.button}
                            </Button>
                        </VStack>
                    </div>
                </div> )
            : (<></>)
            }
        </>
    );
};

const modalContent = {
    background: "white",
    padding: "10px",
    borderRadius: "3px",
};

const overlay = {
    position: "fixed",
    top: 0,
    left: 0,
    width: "100%",
    height: "100%",
    backgroundColor: "rgba(0,0,0,0.7)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
};
