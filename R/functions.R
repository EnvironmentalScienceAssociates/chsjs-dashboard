
percentile <- function(x){
  rank_x = rank(x)
  rank_x/max(rank_x) * 100
}

add_circles <- function(map, ...){
  map |> 
    addCircleMarkers(radius = 6,
                     color = "black",
                     weight = 1,
                     opacity = 1,
                     fillOpacity = 0.8,
                     ...)
}

layout_columns_custom <- function(...){
  layout_columns(
    col_widths = breakpoints(
      sm = c(1, 10, -1),
      md = c(2, 8, -2),
      lg = c(3, 6, -3)
    ),
    img(src = "logo.jpg", alt = "CHSJS logo", width = "70%"),
    ...
  )
}
