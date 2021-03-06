-----------------------------------------------------------------------------
--
-- Module      :  Main
-- Copyright   :  
-- License     :  AllRightsReserved
--
-- Maintainer  :  koval4
-- Stability   :
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

import System.Environment   
import System.Directory  
import System.IO  
import Data.List
import Data.Time
import Data.Time.Format

data Task = Task { description :: String
                 , cost :: Int
                 , deadline :: Day
                 } 
instance Show Task where
    show task = (description task) ++ ", " ++ (show . cost $ task) ++ ", " ++ (formatTime defaultTimeLocale "%d.%m.%Y" $ deadline task)
instance Eq Task where
    a == b =    description a == description b 
             && cost        a == cost        b 
             && deadline    a == deadline    b

makeTask :: String -> Task
makeTask line = let f = span (/= ',') line
                    s = span (/= ',') . drop 1 $ snd f
                    t = span (/= ',') . drop 1 $ snd s
                in Task { description = fst f
                        , cost = read (fst s) :: Int
                        , deadline = parseTimeOrError True defaultTimeLocale "%d.%m.%Y" $ fst t :: Day
                        }

getPriority :: Task -> Day -> Integer
getPriority task dl = let numenator = (toInteger . (*3) . cost $ task)
                          denominator = (diffDays (deadline task) dl)
                      in if denominator > 0 
                            then numenator `div` denominator
                            else toInteger (cost task ^ 3) + abs denominator

getTopTask :: [Task] -> Day -> Task
getTopTask tasks currTime = let priority task = getPriority task currTime
                            in foldl (\acc task -> if priority acc < priority task 
                                                   then task 
                                                   else acc) (head tasks) tasks

makeTasks :: [String] -> [Task]
makeTasks = map makeTask . filter (/= "")

dispatch :: [(String, [String] -> IO ())]
dispatch =  [ ("view", view)
            , ("add", add)
            , ("remove", remove)
            ]

view :: [String] -> IO ()
view [filename] = do
    contents <- readFile filename
    utcCurrDay <- getCurrentTime
    let currDay = utctDay utcCurrDay
        tasks = makeTasks . lines $ contents
    putStrLn $ description . getTopTask tasks $ currDay

remove :: [String] -> IO()
remove [filename] = do
    handle <- openFile filename ReadMode
    (tempName, tempHandle) <- openTempFile "." "temp"
    contents <- hGetContents handle
    utcCurrDay <- getCurrentTime
    let tasks = makeTasks . lines $ contents
        currDay = utctDay utcCurrDay
        newTodo = delete (getTopTask tasks currDay) tasks
    hPutStrLn tempHandle $ unlines . map show $ newTodo
    hClose handle
    hClose tempHandle
    removeFile filename
    renameFile tempName filename

add :: [String] -> IO()
add [filename] = do
    putStrLn "Print new task: "
    line <- getLine
    let newTodo = show . makeTask $ line
    appendFile filename (newTodo ++ "\n")

main :: IO ()
main = do
    (command:args) <- getArgs
    let (Just action) = lookup command dispatch
    action args


