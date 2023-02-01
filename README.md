# Google Analytics 4 with Bigquery
- 기존 UA에서 구글 애널리틱스 4 전환에 따라, 빅쿼리 스키마에 입각하여 필요한 데이터 추출
- 이벤트 중심의 데이터셋으로, 빅쿼리 스토리지 호환을 통해 샤딩 테이블 방식으로 데이터가 적재됨

## 현업에서 활용한 Bigquery Standard SQL 리스트

__1. closed_funnel_5steps__
- 특정 이벤트 순서로 나열된 고객의 이벤트별 전환율 계산
- closed funnel 이란? [링크](https://www.analyticsmania.com/post/open-funnel-vs-closed-funnel-in-google-analytics-4/) 참조 
- 현업에서 활용했던 사례 : 블로그에 게시 (https://is-not-null.tistory.com/5)

__2. closed_funnel_3steps_backfill__
- 위 closed funnel 방식으로 계산되는 이벤트들을 채워넣기 위한 backfill 실행 코드
- bigquery scripting을 활용하였음
- 관련 포스팅 : 블로그에 게시 (https://is-not-null.tistory.com/6)

__3. session_with_high_cpc_term__
- 검색광고를 통한 유입 중에서 특정 키워드를 가지는 유입자들의 실제 유입후 행동 조사
- 이 방식으로 고객 행동 정의를 고민하다가 closed funnel을 발견하게 됌