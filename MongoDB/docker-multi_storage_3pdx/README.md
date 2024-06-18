MongoDB Ver.7.0

MongoDB 버전을 7.0까지 올리면서 mongo명령어가 바뀌어 혼란이 많았다.

먼저 몽고쉘에 진입하는 명령어는 다음과 같이 변경 되었음 :  mongo → mongosh

mognsh 꼭 아이디 비번을 함께 입력하여 접속하여야 한다.

```bash
$ mongosh -u keti_root -p madcoder
```

몽고쉘에 진입 후 레플리카 셋트를 초기화 시켜줘야 작동한다.

```bash
 rs.initiate(
  {
    _id: "rs0",
    version: 1,
    members: [
      { _id: 0, host: "mongo_3pdx:27017" },
      { _id: 1, host: "mongo_3pdx_replica:27017" },
    ]
  }
)
```

## 배포할 때는 이거로 해야 할 수도 있음!

```bash
rs.initiate({_id: "rs0", version: 1, members: [{ _id: 0, host: "mongo_3pdx:27017" },{ _id: 1, host: "mongo_3pdx_replica:27017" }]})
```

## **일단 이걸로 해야 외부에서도 접근 가능하고 잘 됨!**

```bash
rs.initiate({_id: "rs0", version: 1, members: [{ _id: 0, host: "bigsoft.iptime.org:55427" },{ _id: 1, host: "bigsoft.iptime.org:55428" }]})
```

**python 코드!**

```python
# MongoDB 클라이언트 생성
client = MongoClient(
    "mongodb://keti_root:madcoder@bigsoft.iptime.org:55427,bigsoft.iptime.org:55428/?replicaSet=rs0&authSource=admin"
)

```

위 과정이 번거로워 쉘스크립트 작성 후 mongo 서버 실행과 동시에 레플리카셋 초기화 작업을 함께 수행하려고 했으나 안됨…; 정확한 이유는 모르겠음.

결과 화면 :

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/2ad60f02-70e7-4ea0-a0df-094d8cd84aed/1e9d6ce9-d560-44ec-8422-32666505c891/Untitled.png)
