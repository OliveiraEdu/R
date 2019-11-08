gapminder %>%
  filter(gdpPercap < 50000) %>%
  ggplot(aes(x=log(gdpPercap), y=lifeExp, col=continent, size=pop))+geom_point(alpha=0.3)+geom_smooth(method = lm)+facet_wrap(~continent)


