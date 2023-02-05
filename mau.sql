-- (1) 현재 기점의 MAU 계산
-- 빅쿼리 연동 기점이 좀 늦었음. 2022/07/26 부터 잡힌다고 생각해야 맞음
-- _TABLE_SUFFIX 방식을 통해 데이터 날짜 조정 가능함

SELECT COUNT(DISTINCT user_pseudo_id) au
FROM `project.dataset.events_*`
WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY)) AND FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))

-- 멀티 커서 : cmd + d
-- cmd + alt + 위 + 아래 : 멀티커서 위아래로 쓸수 있음

SELECT event_date
   , traffic_source.source
  , COUNT(DISTINCT user_pseudo_id) AS purchasers_count
FROM `dataset.events_20220725`
WHERE
  event_name IN ('in_app_purchase', 'purchase')
GROUP BY 1,2
