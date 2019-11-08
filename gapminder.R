gapminder %>%
select(country, lifeExp) %>%
filter(country=="South Africa" | country=="Ireland") %>%
group_by(country) %>%
summarise(Average_life = mean(lifeExp))


