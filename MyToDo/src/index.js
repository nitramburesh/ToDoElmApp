import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import en from "./translationsEn.json";
import ru from "./translationsRu.json";

const initMainApp = () => {
  const node = document.getElementById("root");

  const flags = {
    baseApiUrl: "https://jsonplaceholder.typicode.com/",
    toDoItems: JSON.parse(localStorage.getItem("to-do-items")),
    accessToken: "",
    translations: { en, ru },
    appWidth: window.innerWidth
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
