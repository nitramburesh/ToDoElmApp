import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import en from "./translationsEn.json";
import ru from "./translationsRu.json";

const initMainApp = () => {
  const node = document.getElementById("root");

  const { ELM_APP_BASE_API_URL } = process.env;

  const flags = {
    baseApiUrl: ELM_APP_BASE_API_URL,
    toDoItems: JSON.parse(localStorage.getItem("to-do-items")),
    accessToken: "accessToken",
    translations: { en, ru },
  };
  const app = Elm.Main.init({
    node,
    flags,
  });
  app.ports.storeItems.subscribe(function (items) {
    localStorage.setItem("to-do-items", JSON.stringify(items));
  });
};

// TODO ---> send and recieve JSON that contains my checked data from local storage

initMainApp();

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
