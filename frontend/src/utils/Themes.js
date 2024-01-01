import { extendTheme } from "@chakra-ui/react";

const colors = {
  primary: {
    100: "#afeeee",
    200: "#add8e6",
    300: "87ceeb",
    400: "#87cefa",
    500: "#00bfff",
    600: "#6495ed",
    700: "#4169e1",
    800: "#1e90ff",
    900: "#0000ff"
  }
};

const customTheme = extendTheme({ colors });

export default customTheme;
