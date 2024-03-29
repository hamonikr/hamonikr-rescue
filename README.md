# 하모니카 사용자를 위한 백업 및 복구 프로그램

이 프로그램이 다른 백업프로그램과 다른 점은 설치 후 전체 하드디스크의 복구 이미지를 압축하여 자동으로 백업 및 복구를 지원한다는 점입니다.

설치 시 Recommend Mode 를 선택하면 자동으로 백업할 파티션을 생성하고, 추후 문제가 생기면 재 설치가 가능한 상태로 만들어 줍니다.

[주의] 이 프로그램은 시스템에 설치해서 사용하는 것이 아니라, ISO 이미지를 생성하는 단계에서 사용하는 프로그램입니다.

## workflow

![workflow](hamonikr-rescue.png)

- image src : https://app.creately.com/diagram/L7iKmJe27gO/edit


# License

GPL 2.0

# 사용법

## 백업을 원하는 경우
설치를 마친 후 시스템을 재시작 합니다.
터미널을 열고 hamonikr_rescue backup 명령어를 실행하면 자동으로 현재 하드디스크의 상태를 백업하게 됩니다. (명령을 실행하면 시스템이 자동으로 재시작 됩니다.)

```
$ hamonikr_rescue backup
```

백업된 이미지는 압축되어 저장되게 되므로 전체 하드시스크를 백업하는 데 7-8 G 정도 사용됩니다.

## 복구를 원하는 경우

터미널을 열고 hamonikr_rescue restore 명령어를 실행하면 자동으로 이전 백업시점으로 복원하게 됩니다. (명령을 실행하면 시스템이 자동으로 재시작 됩니다.)

```
$ hamonikr_rescue restore
```

# Release

* hamonikr-rescue 1.5 (2019-06-15)
* hamonikr-rescue 1.0 (2016-12-10)

# 다른 OS에서 사용을 원하는 경우

1) ISO 이미지를 제작할 때 preseed 디렉토리의 내용을 모두 ISO 이미지 안으로 복사합니다.
2) 부트로더에서 hamonikr.seed 파일을 지정하여 사용할 수 있도록 지정해 줍니다.

