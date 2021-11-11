import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

const initMainApp = () => {
  const node = document.getElementById("root");

  const base_url = process.env.ELM_APP_BASE_API_URL;

  Elm.Main.init({
    node,
    flags: { base_url },
  });
};

initMainApp();

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
