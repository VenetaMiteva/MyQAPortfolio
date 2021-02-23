-- 1. Брой на потребители.
SELECT COUNT(id)
FROM users;


-- 2. Най-старият потребител.
SELECT * FROM users
ORDER BY birthDate ASC
LIMIT 1


-- 3. Най-младият потребител.
SELECT * FROM users
ORDER BY birthDate DESC
LIMIT 1


-- 4. Колко юзъра са регистрирани с мейли от abv, колко от gmail и колко с различни от двата.
SELECT COUNT(*) FROM users
WHERE email LIKE '%@abv.%';
SELECT COUNT(*) FROM users
WHERE email LIKE '%@gmail.%';
SELECT COUNT(*) FROM users
WHERE email NOT LIKE '%@abv.%' AND email NOT LIKE '%@gmail.%';


-- 5. Кои юзъри са banned.
SELECT * FROM users
WHERE isBanned != 0;


-- 6. Изкарайте всички потребители от базата, като ги наредите по име в азбучен ред и дата на раждане (от най-младия към най-възрастния).
SELECT username FROM users
ORDER BY username ASC;
SELECT birthDate FROM users
ORDER BY birthDate DESC;


-- 7. Изкарайте всички потребители от базата, на които потребителското име започва с a.
SELECT username FROM users
WHERE username LIKE 'a%';


-- 8. Изкарайте всички потребители от базата, които съдържат а в името си.
SELECT username FROM users
WHERE username LIKE '%a%';


-- 9. Изкарайте всички потребители от базата, чието име се състои от 2 имена.
SELECT username FROM users
WHERE TRIM(username) LIKE "% %";


-- 10. Регистрирайте 1 юзър през UI-а и го забранете след това от базата.
UPDATE users 
SET isBanned = 1
WHERE email = 'fsdfs@safdsf.bg';


-- 11. Брой на всички постове.
SELECT COUNT(*) FROM posts;


-- 12. Брой на всички постове, групирани по статуса на post-a.
SELECT COUNT(*) FROM posts
GROUP BY postStatus;


-- 13. Намерете поста/овете с най-къс caption.
SELECT * FROM posts
WHERE LENGTH(TRIM(caption)) = (SELECT LENGTH(TRIM(caption)) FROM posts
WHERE LENGTH(TRIM(caption)) > 0
ORDER BY LENGTH(caption) ASC 
LIMIT 1)
ORDER BY LENGTH(caption) ASC


-- 14. Покажете поста с най-дълъг caption.
SELECT * FROM posts
WHERE LENGTH(caption) = (SELECT LENGTH(caption) FROM posts
ORDER BY LENGTH(caption) DESC 
LIMIT 1)
ORDER BY LENGTH(caption) DESC


-- 15. Кой потребител има най-много постове. Използвайте join заявка.
SELECT users.id, COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
ORDER BY cnt_posts DESC
LIMIT 1;


-- 16. Кои потребители имат най-малко постове. Използвайте join заявка.
SELECT users.id, COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
HAVING cnt_posts = (SELECT COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
ORDER BY cnt_posts ASC
LIMIT 1)
ORDER BY cnt_posts ASC;


-- 17. Колко потребителя с по 1 пост имаме. Използвайте join заявка, having clause и вложени заявки.
SELECT users.id, COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
HAVING cnt_posts = (SELECT COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
HAVING COUNT(posts.id) > 0
ORDER BY cnt_posts ASC
LIMIT 1)
ORDER BY cnt_posts ASC;


-- 18. Колко потребителя с по-малко от 5 поста имаме. Използвайте join заявка, having clause и вложени заявки.
SELECT users.id, COUNT(users.id) AS cnt_users, COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
HAVING cnt_posts <= (SELECT COUNT(posts.id) AS cnt_posts
FROM users
LEFT JOIN posts
ON users.id = posts.userId
GROUP BY users.id
HAVING COUNT(posts.id)  <= 5  
ORDER BY cnt_posts DESC
LIMIT 1)
ORDER BY cnt_posts DESC;


-- 19. Кои са постовете с най-много коментари. Използвайте вложена заявка и where clause.
SELECT posts.* FROM posts
WHERE posts.id IN (SELECT postId FROM comments)
ORDER BY posts.commentsCount DESC


-- 20. Покажете най-стария пост. Може да използвате order или aggregate function.
SELECT * FROM posts
ORDER BY createdAt ASC
LIMIT 1;


-- 21. Покажете най-новия пост. Може с order или с aggregate function.
SELECT * FROM posts
ORDER BY createdAt DESC
LIMIT 1;


-- 22. Покажете всички постове с празен caption.
SELECT * FROM posts
WHERE LENGTH(caption) = (SELECT LENGTH(caption) FROM posts
ORDER BY LENGTH(caption) ASC 
LIMIT 1)
ORDER BY LENGTH(caption) ASC


-- 23. Създайте потребител през UI-а, добавете му public пост през базата и проверете дали се е създал през UI-а.
INSERT INTO posts
(caption, coverUrl, postStatus, createdAt, isDeleted, commentsCount, userId)
VALUES ('Time stops', 'https://cdn.cdnparenting.com/articles/2020/04/04145119/348883676.jpg', 'public', NOW(), 0, 0, 
(SELECT id FROM users WHERE email = 'test12@test.test'));


-- 24. Покажете всички постове и коментарите им, ако имат такива.
SELECT posts.id, posts.caption, posts.coverUrl, comments.content
FROM posts
LEFT JOIN comments
ON comments.userId = posts.userId


-- 25. Покажете само постове с коментари и самите коментари.
SELECT posts.id, posts.caption, posts.coverUrl, comments.content
FROM posts
LEFT JOIN comments
ON comments.userId = posts.userId
WHERE content IS NOT NULL AND TRIM(content) != '' 


-- 26. Покажете името на потребителя с най-много коментари. Използвайте join клауза.
SELECT users.username, comments.userId
FROM users
LEFT JOIN comments
ON users.id = comments.userId
WHERE userId = (SELECT userId FROM comments
GROUP BY userId
ORDER BY COUNT(*) DESC
LIMIT 1)
GROUP BY userId


-- 27. Покажете всички коментари, към кой пост принадлежат и кой ги е направил. Използвайте join клауза.
SELECT comments.content, posts.caption, users.username
FROM comments
LEFT JOIN posts
ON comments.postId = posts.userId
LEFT JOIN users
ON postId = users.id


-- 28. Кои потребители са like-нали най-много постове.
SELECT usersId, COUNT(postsId) AS cnt FROM users_liked_posts
GROUP BY usersId
ORDER BY cnt DESC


-- 29. Кои потребители не са like-вали постове.
SELECT users.* FROM users
LEFT JOIN users_liked_posts 
ON users.id = users_liked_posts.usersId
WHERE users.id NOT IN (SELECT usersId FROM users_liked_posts)


-- 30. Кои постове имат like-ове. Покажете id на поста и caption.
SELECT users_liked_posts.postsId, posts.caption
FROM users_liked_posts
LEFT JOIN posts
ON postsId = posts.id


-- 31. Кои постове имат най-много like-ове. Покажете id на поста и caption.
SELECT postsId, posts.caption, COUNT(usersId) AS cnt 
FROM users_liked_posts
LEFT JOIN posts
ON postsId = posts.id
GROUP BY postsId
ORDER BY cnt DESC


-- 32. Покажете всички потребители, които не follow-ват никого.
SELECT users.id, users.username FROM users
LEFT JOIN users_followers_users 
ON users.id = users_followers_users.usersId_2
WHERE users.id NOT IN (SELECT usersId_2 FROM users_followers_users)


-- 33. Покажете всички потребители, които не са follow-нати от никого.
SELECT users.id, users.username FROM users
LEFT JOIN users_followers_users 
ON users.id = users_followers_users.usersId_1
WHERE users.id NOT IN (SELECT usersId_1 FROM users_followers_users)


-- 34. Регистрирайте потребител през UI. Follow-нете някой съществуващ потребител и проверете дали записа го има в базата.
SELECT * FROM users_followers_users
WHERE usersId_2 = (SELECT id FROM users WHERE email = 'test21@test.test')
