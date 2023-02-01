DECLARE event_day DATE;
SET event_day = DATE(2022, 11, 01);


     SELECT step1_event_date as event_date
      , stream_id
      , COUNT(DISTINCT step1_id) AS page_view_users
      , COUNT(DISTINCT step2_id) AS view_item_users
      , COUNT(DISTINCT step3_id) AS add_to_cart_users
      , COUNT(DISTINCT step4_id) AS begin_checkout_users
      , COUNT(DISTINCT step5_id) AS purchase_users    
      FROM (
      -- STEP 1. page_view
      SELECT
        (CASE WHEN stream_id = 'your_stream_id' THEN 'WEB' ELSE 'APP' END) as stream_id
        , event_date as step1_event_date
        , user_pseudo_id AS step1_id
        , event_timestamp AS step1_timestamp
        , step2_id
        , step2_timestamp
        , step3_id
        , step3_timestamp
        , step4_id
        , step4_timestamp
        , step5_id
        , step5_timestamp
      FROM
        `your_dataset_table.events_*`

      LEFT JOIN 
        (
        -- STEP 2. page_view -> view_item
        SELECT
          event_date as step2_event_date
          , user_pseudo_id AS step2_id
          , event_timestamp AS step2_timestamp
        FROM
          `your_dataset_table.events_*`
        WHERE
          _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
          AND event_name = "view_item" )
      ON
        user_pseudo_id = step2_id
      AND event_timestamp < step2_timestamp

      LEFT JOIN (
        -- STEP 4. view_item -> add_to_cart
        SELECT
          event_date as step3_event_date,
          user_pseudo_id AS step3_id,
          event_timestamp AS step3_timestamp
        FROM
          `your_dataset_table.events_*`
        WHERE
          _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
          AND event_name = "add_to_cart" )
        ON
        step3_id  = step2_id
        AND step2_timestamp < step3_timestamp
        
      LEFT JOIN (
        -- STEP 4. add_to_cart -> begin_checkout
        SELECT
          event_date as step4_event_date,
          user_pseudo_id AS step4_id,
          event_timestamp AS step4_timestamp
        FROM
          `your_dataset_table.events_*`
        WHERE
          _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
          AND event_name = "begin_checkout" )
        ON
        step4_id  = step3_id
        AND step3_timestamp < step4_timestamp


        LEFT JOIN 
        (
        -- STEP 5. begin_checkout -> purchase
        SELECT
          event_date as step5_event_date
          , user_pseudo_id AS step5_id
          , event_timestamp AS step5_timestamp
        FROM
          `your_dataset_table.events_*`
        WHERE
          _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
          AND event_name = "purchase" )
      ON
        step5_id = step4_id
      AND step4_timestamp < step5_timestamp

      -- STEP 1. view_item의 where
      WHERE
          _TABLE_SUFFIX BETWEEN format_date('%Y%m%d',event_day) AND format_date('%Y%m%d',event_day)
          AND event_name = "page_view" 
    )
    group by
      stream_id
      , event_date