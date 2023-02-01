

-- 특정 소스 조건 및 키워드 확인
with high_cpc_user as (
  select distinct user_pseudo_id
  from `your_data_project.your_data_set.events_20221009`
  where traffic_source.source = 'naver'
  and traffic_source.medium = 'cpc'
  and (select value.string_value from unnest(event_params) where key = 'term') = 'your_term'
)

-- SELECT
--   TIMESTAMP_DIFF(CAST('2021-01-01 14:01:05' AS TIMESTAMP), CAST('2021-01-01 12:22:23' AS TIMESTAMP), MINUTE) AS minutes_difference,
--   TIMESTAMP_DIFF(CAST('2021-01-01 01:44:33' AS TIMESTAMP), CAST('2020-12-31 22:04:60' AS TIMESTAMP), MILLISECOND) AS millisecond_difference


-- 특정한 content_group 별로 url을 매칭하여 확인 (너무 많은 url이 존재하여, 페이지의 대분류 기준으로 보고자 하였음)
select user_pseudo_id
     , date
     , prev_date
     , TIMESTAMP_DIFF(cast(date as TIMESTAMP), cast (prev_date as TIMESTAMP), SECOND) as diff_sec
     -- 몇몇 url의 경우 content_group으로 등록이 되지 않았기에 예외 처리함
     , CASE WHEN url like '%/order/orderform.html%' THEN '주문서작성'
            WHEN url like '%/order/order_result.html%' THEN '주문완료'
            WHEN url like '%/board/magazine%' THEN '매거진'
            ELSE content_group END AS content_group
     , url
     , source
     , medium
     , term
     , page_title
from (
  select user_pseudo_id
        , FORMAT_TIMESTAMP('%Y-%m-%d %T',TIMESTAMP_ADD(TIMESTAMP_MICROS(event_timestamp), INTERVAL 9 hour)) as date
        , lag(FORMAT_TIMESTAMP('%Y-%m-%d %T',TIMESTAMP_ADD(TIMESTAMP_MICROS(event_timestamp), INTERVAL 9 hour))) over (partition by user_pseudo_id order by FORMAT_TIMESTAMP('%Y-%m-%d %T',TIMESTAMP_ADD(TIMESTAMP_MICROS(event_timestamp), INTERVAL 9 hour)) asc) as prev_date
        , (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'content_group') as content_group
        , (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as url
        , (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'source') as source
        , (select value.string_value from unnest(event_params) where key = 'medium') as medium
        , (select value.string_value from unnest(event_params) where key = 'term') as term
        , (select value.string_value from unnest(event_params) where key = 'page_title') as page_title
  from `your_data_project.your_data_set.events_20221009`
  where stream_id = '3853099964'
  and event_name = 'page_view'
)
where user_pseudo_id in (select user_pseudo_id from high_cpc_user)
order by 1,2