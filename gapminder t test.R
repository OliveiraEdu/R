df1 <-gapminder %>%
  select(country, lifeExp) %>%
  filter(country=="South Africa" | country=="Ireland")
  t.test(data=df1,lifeExp ~ country)
