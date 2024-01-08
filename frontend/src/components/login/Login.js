import { Text, Flex, Input, Button, Heading, Center, Divider, TagLabel } from '@chakra-ui/react';
import { FormControl, FormLabel, FormHelperText, FormErrorMessage } from '@chakra-ui/form-control';
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

// TODO 作成中
export default function Login (props) {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [emailError, setEmailError] = useState('')
    const [passwordError, setPasswordError] = useState("")

    const navigate = useNavigate();

    const handleEmailChange = (e) => {
        setEmail(e.target.value);
    }

    const handlePasswordChange = (e) => {
        setPassword(e.target.value);
    }

    const isEmailError = email === '';
    const isPasswordError = password === '';

    const onMotherLoginButtonClick = () => {
        if (email === '') {
            setEmailError("メールアドレスを入力してください");
            return;
        }
        if (!/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/.test(email)) {
            setEmailError("有効なメールアドレスを入力してください");
            return;
        }
        if (password === "") {
            setPasswordError("パスワードを入力してください");
            return;
        }
        if (password.length < 3) {
            setPasswordError('パスワードは4文字以上にしてください');
            return;
        }
    }

    return (
        <Center
            h="100vh"
            style={{backgroundImage: `url("/assets/imgs/top.jpg")` }}>
            <Flex 
                height="100vh" 
                alignItems="center" 
                justifyContent="center">
                <Flex 
                    direction="column" 
                    background="gray.100" 
                    padding={12} 
                    rounded={12}>
                    <Heading mb={6} ml={12} mr={12}>
                        お母さんへ
                    </Heading>
                    <FormControl mb={3}>
                        <FormLabel>Email</FormLabel>
                        <Input type='email' placeholder="yamda.taro@mother.com" plavalue={email} onChange={handleEmailChange} />
                    </FormControl>
                    <FormControl mb={9}>
                        <FormLabel>password</FormLabel>
                        <Input type='password' placeholder="****" plavalue={password} onChange={handlePasswordChange} />
                        <FormHelperText>
                        {/* {!isPasswordError ? (
                            <Text>"{passwordError}"</Text>
                        ) : (
                            <Text>こんにちは2</Text>
                        )} */}
                        </FormHelperText>
                    </FormControl>
                    <Button 
                        mb={3} 
                        colorScheme="teal"
                        onClick={onMotherLoginButtonClick}>
                            向かいます
                    </Button>
                </Flex>
            </Flex>
        </Center>
    )

}