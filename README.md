# GetMother

お母さんいいですか？

- ## frontend preparation

```
  cd frontend
  npm install
  npm start
```

  <h4> Access http://localhost:9000/ on any browser. 
  <br>Let's meet your mothers.

<br><br>

- ## image server preparation

```
  cd images
  cabal install --lib random wai warp HTTP http-type
  runhaskell ImageServer.hs
```
