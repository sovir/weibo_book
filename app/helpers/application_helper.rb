# -*- coding: utf-8 -*-
module ApplicationHelper
  include Hashie

  def season(date)
    day_hash = date.month * 100 + date.mday
    case day_hash
    when 201..430 then :spring
    when 501..731 then :summer
    when 801..1031 then :fall
    when (1101..1231 or 101..131) then :winter
    end
  end
  
  def next_chapter(all_statuses)
    poetry = {:Jan => "不道春归逾一月，起闻歌鸟尚疑莺",
              :Feb => "不知细叶谁裁出，二月春风似剪刀",
              :Mar => "三月香巢已垒成，梁间燕子太无情",
              :Apr => "人间四月芳菲尽，山寺桃花始盛开",
              :May => "平湖潋滟带垂杨，绿暗长堤五月凉",
              :Jun => "古木阴阴六月凉，幽花藉藉四时香",
              :Jul => "七月江边暑已微，虚窗卧看雨霏霏",
              :Aug => "八月金茎露有结，晨曦缠上散余霞",
              :Sep => "可怜九月初三夜，露似珍珠月似弓",
              :Oct => "江南十月天雨霜，人间草木不敢芳",
              :Nov => "十一月中长至夜，三千里外远行人",
              :Dec => "日晏霜浓十二月，林疏石瘦第三溪"}
    theme = {:spring => "#32cd32", # limegreen
             :summer => "#1e90ff", # dodgerblue
             :fall => "#ffa500", # orange
             :winter => "#ffb6c1"} # lightpink
    chapter = Mash.new
    first_status = all_statuses.first
    first_day = Date.parse(first_status.created_at)
    chapter.month = first_day.month
    chapter.poetry = poetry[first_day.strftime("%b").to_sym]
    chapter.season = season(first_day)
    chapter.theme = theme[chapter.season]
    chapter.first_day = first_day
    chapter.statuses = []
    while Date.parse(all_statuses.first.created_at).month == first_day.month do
      chapter.statuses << all_statuses.shift
      break if all_statuses.empty?
    end
    
    return chapter
  end
end
