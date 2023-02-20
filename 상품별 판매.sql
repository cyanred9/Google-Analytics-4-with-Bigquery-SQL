ELECT  FORMAT_TIMESTAMP('%Y-%m-%d',TIMESTAMP_ADD(TIMESTAMP_MICROS(event_timestamp), INTERVAL 9 hour)) as date
   , ecommerce.transaction_id 
   , item.item_name
   , item.price
   , count(distinct user_pseudo_id)
FROM `your_ga_data`, unnest(items) as item
where event_name = 'purchase'
and stream_id = 'your_stream_id'
and _table_suffix between '20220901' and '20220902'
group by 1,2,3,4
