extract_meta = function (json_data) {
  now = new Date()
  return json_data.map(function(item) {
    //release date
    rdate = new Date(item.release_date)
    item.release_date = rdate.getFullYear() + "-" + (rdate.getMonth()+1) + "-" + rdate.getDate()
    if ( now-rdate < 604800000 ) {
      item.release_date = "<font color=\"red\">" + item.release_date + "</font>"
    }

    // title
    item.title = "<a href=\"" + item.card_url + "\">" + item.title + "</a>"
    if (item.subtitle) {
      item.title = item.title + "</br>" + item.subtitle;
    }
    // author
    item.author = item.last_name + " " + item.first_name

    return item;
  });
}

whatsnew = function (start_date) {
  $.ajax({
    url:'/api/v0.1/books?fields=release_date,title,subtitle,card_url,first_name,last_name,input,proofing&after='+start_date,
    dataType: 'json',
    success: function(json_data) {
      tbl = $('#tbl').columns({
        data: extract_meta(json_data),
        schema: [
          {"header": "公開日", "key": "release_date"},
          {"header": "作品名/副題", "key": "title"},
          {"header": "著者名", "key": "author"},
          {"header": "入力者名", "key": "input"},
          {"header": "校正者名", "key": "proofing"},
        ],
        showRows: [10, 25, 50, 100],
        size: 10
      });
    }
  })
}
