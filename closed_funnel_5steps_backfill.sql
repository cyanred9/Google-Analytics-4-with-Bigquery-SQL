DECLARE i INT64 DEFAULT 0;
DECLARE DATES ARRAY<DATE>;
DECLARE event_day DATE;
  
SET DATES = GENERATE_DATE_ARRAY(DATE(2022,8,1), DATE(2022,11,10), INTERVAL 1 DAY);

LOOP
    -- SET : 반복문 횟수 카운트
    SET i = i + 1;  

    -- IF : DATES ARRAY의 횟수를 넘기지 않도록 조정
    -- 여기서 크게 필요하지는 않음
    IF i > ARRAY_LENGTH(DATES) THEN LEAVE; 
    END IF;

    -- ORDINAL : i번째 요소에 접근하고 싶은 경우 OFFSET 또는 ORDINAL을 사용
    SET event_day = DATES[ORDINAL(i)];

    INSERT INTO `your_data_project.your_dataset.closed_funnel_3steps`
    
    WITH data as (
      SELECT
    step1_event_date as event_date
    , stream_id
    , COUNT(DISTINCT step1_id) AS view_item_users
    , COUNT(DISTINCT step2_id) AS begin_checkout_users
    , COUNT(DISTINCT step3_id) AS purchase_users
  FROM (
    -- STEP 1. view_item
    SELECT
      (CASE WHEN stream_id = '3853099964' THEN 'WEB' ELSE 'APP' END) as stream_id
      , event_date as step1_event_date
      , user_pseudo_id AS step1_id
      , event_timestamp AS step1_timestamp
      , step2_id
      , step2_timestamp
      , step3_id
      , step3_timestamp
    FROM
      `your_data_project.your_dataset.events_*`
    LEFT JOIN 
      (
      -- STEP 2. view_item -> begin_checkout
      SELECT
        event_date as step2_event_date
        , user_pseudo_id AS step2_id
        , event_timestamp AS step2_timestamp
      FROM
        `your_data_project.your_dataset.events_*`
      WHERE
        _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
        AND event_name = "begin_checkout" )
    ON
      user_pseudo_id = step2_id
    AND event_timestamp < step2_timestamp
      
    LEFT JOIN (
      -- STEP 3. view_item -> begin_checkout -> purchase
      SELECT
        event_date as step3_event_date,
        user_pseudo_id AS step3_id,
        event_timestamp AS step3_timestamp
      FROM
        `your_data_project.your_dataset.events_*`
      WHERE
        _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
        AND event_name = "purchase" )
    ON
      step3_id  = step2_id
      AND step2_timestamp < step3_timestamp
    -- STEP 1. view_item의 where
    WHERE
        _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
        AND event_name = "view_item" 
  )
  group by
    stream_id
    , event_date
  )
  select * from data;
END LOOP;