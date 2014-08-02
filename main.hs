{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Main where

import Model
import Web.Spock
import Data.Text
import Control.Monad.IO.Class (liftIO)

import qualified DB

dPort = 3000

main = do
	DB.initDB
	putStrLn "To exit press [CTRL + C]"
	spockT dPort id $ runUrl

runUrl = do
		get  "/" 			  mainPage
		get  "/get/:pID"	  getPlayer
		post "/postScore"     postScore
		post "/uScore/easy"   (updateScore LeaderboardScoreEasy)
		post "/uScore/medium" (updateScore LeaderboardScoreMedium)
		post "/uScore/hard"   (updateScore LeaderboardScoreHard)

--------------------------------------------

mainPage = html $ "<center><h1> Hi There! Well, you should go. </h1></center>"

getPlayer = do
	(Just pID :: Maybe Text) <- param "pID"
	out <- liftIO $ DB.getByID pID
	json $ DB.extract out

postScore = do
	(Just id :: Maybe Text) <- param "pID"
	(Just s1 :: Maybe Int)    <- param "sE"
	(Just s2 :: Maybe Int)    <- param "sM"
	(Just s3 :: Maybe Int)    <- param "sH"
	addPlayer $ newPID id s1 s2 s3	
	jSucces

updateScore rec = do 
			(Just id :: Maybe Text) <- param "pID"
			(Just score :: Maybe Int) <- param "nScore"
			liftIO $ DB.runDB $ DB.updateScore' id rec score
			jSucces

addPlayer player = liftIO $ DB.insertPerson player

emptyPage = text ""

jSucces = json $ ["done" :: Text]

newPID :: Text -> Int -> Int -> Int -> Leaderboard
newPID id s1 s2 s3 = Leaderboard id s1 s2 s3
