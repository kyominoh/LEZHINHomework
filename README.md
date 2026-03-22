# LEZHINHomework

카카오 이미지 검색 API를 활용한 이미지 검색 및 북마크 iOS 앱입니다.

---

## 주요 기능

- **이미지 검색** : 카카오 이미지 검색 API를 통해 키워드로 이미지 검색
- **무한 스크롤** : 스크롤 끝에 도달 시 다음 페이지 자동 로드
- **검색 디바운스** : 입력 후 1초 대기 후 검색 요청 (중복 호출 방지)
- **북마크** : 이미지 우측 상단 하트 버튼으로 북마크 추가/제거
- **북마크 목록** : 저장된 북마크를 최신순으로 확인
- **스와이프 삭제** : 북마크 목록에서 좌측 스와이프로 항목 삭제
- **이미지 캐싱** : 메모리 + 디스크 2단계 캐시로 네트워크 요청 최소화

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| 언어 | Swift 6 |
| UI | SwiftUI |
| 아키텍처 | TCA (The Composable Architecture) |
| 네트워크 | URLSession |
| 로컬 저장소 | UserDefaults |
| 외부 API | Kakao 이미지 검색 API |
| 의존성 관리 | Swift Package Manager |

---

## 아키텍처

TCA(The Composable Architecture) 패턴을 기반으로 단방향 데이터 흐름을 따릅니다.

```
View → Action → Reducer → State → View
```

### 레이어 구조

```
┌─────────────────────────────────────┐
│               View Layer            │
│   ContentView / SearchView /        │
│   BookmarkView / CacheImageView     │
├─────────────────────────────────────┤
│            Feature Layer (TCA)      │
│   ContentFeature                    │
│   ├── SearchFeature                 │
│   └── BookmarkFeature               │
├─────────────────────────────────────┤
│            Client Layer             │
│   SearchClient / BookmarkClient     │
│   (DependencyKey, TCA Dependency)   │
├─────────────────────────────────────┤
│            Usecase Layer            │
│   SearchUsecase / BookmarkUsecase   │
├─────────────────────────────────────┤
│          Repository Layer           │
│   SearchRepository                  │
│   BookmarkRepository (UserDefaults) │
├─────────────────────────────────────┤
│           Network Layer             │
│   NetworkWorker / KakaoApiRequest   │
│   KakaoResponse / NetworkError      │
└─────────────────────────────────────┘
```

---

## 프로젝트 구조

```
LEZHINHomework/
├── LEZHINHomeworkApp.swift       # 앱 진입점
├── ContentView.swift             # TabView 루트 뷰
├── ContentFeature.swift          # 탭 상태 관리 Reducer
│
├── Search/
│   ├── SearchView.swift          # 검색 화면 UI
│   ├── SearchFeature.swift       # 검색 Reducer & State
│   ├── SearchClient.swift        # TCA Dependency 래퍼
│   ├── SearchUsecase.swift       # 검색 비즈니스 로직
│   └── SearchRepository.swift   # Kakao API 호출
│
├── Bookmark/
│   ├── BookmarkView.swift        # 북마크 화면 UI
│   ├── BookmarkFeature.swift     # 북마크 Reducer & State
│   ├── BookmarkClient.swift      # TCA Dependency + AsyncStream
│   ├── BookmarkUsecase.swift     # 북마크 비즈니스 로직
│   └── BookmarkRepository.swift # UserDefaults CRUD
│
├── Network/
│   ├── KakaoApi.swift            # API 엔드포인트 정의
│   ├── KakaoResponse.swift       # 응답 모델
│   ├── NetworkRequest.swift      # 네트워크 프로토콜 & URLSession 처리
│   └── NetworkError.swift        # 에러 타입 정의
│
├── Manager/
│   ├── MemoryCacheManager.swift  # NSCache 기반 메모리 캐시
│   └── DiskCacheManager.swift   # 파일시스템 기반 디스크 캐시
│
└── CacheImageView.swift          # 이미지 로딩 & 캐시 뷰 컴포넌트
```

---

## 핵심 설계 상세

### TCA Feature 구성

`ContentFeature`가 루트 Reducer로 `SearchFeature`와 `BookmarkFeature`를 `Scope`로 합성합니다.

```swift
Scope(state: \.search, action: \.search) { SearchFeature() }
Scope(state: \.bookmark, action: \.bookmark) { BookmarkFeature() }
```

### 북마크 실시간 동기화

북마크 변경 시 `SearchView`와 `BookmarkView` 양쪽에 즉시 반영됩니다.
`UserDefaults.didChangeNotification`을 `AsyncStream`으로 감싸 TCA Effect로 수신합니다.

```
UserDefaults 변경
    → NotificationCenter
    → AsyncStream<[BookmarkItem]>
    → bookmarkStream Effect
    → updateBookmarkList Action
    → State 업데이트 → UI 리렌더링
```

### 이미지 캐싱 전략

네트워크 요청을 최소화하기 위해 2단계 캐시를 사용합니다.

```
요청
 └─ 메모리 캐시 (NSCache) 확인
      ├─ Hit → 즉시 반환
      └─ Miss → 디스크 캐시 확인
                ├─ Hit → 반환
                └─ Miss → 네트워크 요청
                          └─ 메모리 + 디스크 양쪽 저장 (실패 시 1회 재시도)
```

### 검색 디바운스

`ContinuousClock`을 활용해 1초 디바운스를 구현합니다. 이전 검색 Effect를 `cancelInFlight: true`로 취소하여 불필요한 API 호출을 방지합니다.

```swift
.run { send in
    try await clock.sleep(for: .seconds(1))
    await send(.searchTextChanged(input))
}
.cancellable(id: searchCancelID, cancelInFlight: true)
```

---

## 의존성 주입 (DI)

TCA의 `Dependencies` 라이브러리를 활용하여 의존성을 주입합니다.

### 구조

```
Reducer (@Dependency)
    └── Client (DependencyKey)
            └── Usecase
                    └── Repository
```

Feature는 구체 구현체(Repository, Usecase)를 직접 참조하지 않고, `Client`를 통해서만 접근합니다. Client가 DI의 경계 역할을 합니다.

### Client 등록

`DependencyKey` 프로토콜을 채택하여 `liveValue`에 실제 구현체를 조합합니다.

```swift
extension SearchClient: DependencyKey {
    public static var liveValue: SearchClient {
        let usecase = SearchUsecase(
            searchRep: SearchRepository(),
            bookmarkRepo: BookmarkRepository()
        )
        return Self(
            search: { input, page in
                try await usecase.search(input: input, page: page)
            }
        )
    }
}
```

### Feature에서 주입

`@Dependency` 프로퍼티 래퍼로 선언하면 TCA 컨테이너가 자동으로 주입합니다.

```swift
@Reducer
public struct SearchFeature {
    @Dependency(SearchClient.self) var searchClient
    @Dependency(BookmarkClient.self) var bookmarkClient
    @Dependency(\.continuousClock) var clock  // TCA 내장 의존성
}
```

### 테스트 시 교체

`withDependencies`를 통해 테스트 환경에서 실제 구현체를 Mock으로 교체할 수 있습니다.

```swift
let store = TestStore(initialState: SearchFeature.State()) {
    SearchFeature()
} withDependencies: {
    $0[SearchClient.self] = .mock   // Mock으로 교체
    $0[BookmarkClient.self] = .mock
}
```

### 검색 탭
- 상단 텍스트 필드에 검색어 입력
- 결과 이미지 목록 (무한 스크롤)
- 각 이미지 우측 상단 하트 버튼으로 북마크 토글
- 마지막 페이지 도달 시 총 결과 수 표시

### 북마크 탭
- 북마크된 이미지 최신순 목록
- 하트 버튼 또는 좌측 스와이프 → 삭제 버튼으로 북마크 제거

### 잠재적 이슈
- API 키 보안 안됨
- DB 구조가 방대해질 경우 UserDefault 로는 적용 비 추천

### AI 사용 영역 (Claude AI)
- 문서 작성
- 잠재 버그 색출용 검색
