--PREMIERE PARTIE

import Parser
import Data.Maybe

type Nom = String

data Expression = Lam Nom Expression
                | App Expression Expression
                | Var Nom
                | Lit Litteral
                deriving (Show,Eq)

data Litteral = Entier Integer
              | Bool   Bool
              deriving (Show,Eq)
                       
--Q1
                       
espacesP :: Parser ()
espacesP = (car ' ' >>= \_ -> 
               espacesP >>= \s ->
               return s) ||| return ()
           
--Q2

isMin :: Char -> Bool
isMin = flip elem ['a'..'z']

minP :: Parser [Char]
minP = unOuPlus (carCond isMin)

nomP :: Parser Nom
nomP = ( minP >>= \s ->
         espacesP >>= \_ ->
         return s) ||| echoue
       
--Q3

varP :: Parser Expression
varP = (nomP >>= \s ->
         return (Var s))
       
--Q4

applique :: [Expression] -> Expression
applique (e:es) = foldl (\x y -> App x y) e es

--Q5

exprP :: Parser Expression
exprP = booleenP ||| nombreP ||| varP ||| lambdaP ||| exprParentheseeP         

exprsP :: Parser Expression
exprsP = (unOuPlus exprP >>= \s ->
           return (applique s))
         
--Q6

flecheP :: Parser ()
flecheP = (car '-' >>= \_ ->
           car '>' >>= \s ->
           espacesP >>= \_ ->
           return ()) ||| echoue

lambdaP :: Parser Expression
lambdaP = (car 'λ' >>= \_ ->
           espacesP >>= \_ ->
           nomP >>= \p ->
           flecheP >>= \_ ->
           exprsP >>= \s -> 
           return (Lam p s)) ||| echoue

--Q7 voir Q5

--Q8

exprParentheseeP :: Parser Expression
exprParentheseeP = (car '(' >>= \_  ->
                    espacesP >>= \_ ->
                    unOuPlus exprP >>= \e ->
                    car ')' >>= \_ ->
                    espacesP >>= \_ ->
                    return (applique e)
                   )
             
--Q9

isChiffre :: Char -> Bool
isChiffre = flip elem ['1'..'9']

nombreP :: Parser Expression
nombreP = ( unOuPlus (carCond isChiffre) >>= \n ->
            espacesP >>= \_ ->
            return (Lit (Entier (read n))))

--Q10

booleenP :: Parser Expression
booleenP = (chaine "True" >>= \_ ->
            espacesP >>= \_ ->
            return (Lit (Bool True))) |||
           (chaine "False" >>= \_ ->
            espacesP >>= \_ ->
            return (Lit (Bool False)))

--Q11

expressionP :: Parser Expression
expressionP = (espacesP >>= \_ ->
               exprsP >>= \r ->
               return r)

--SECONDE PARTIE
--Q12

getExp Nothing = error "error parse"
getExp (Just (e,"")) = e
getExp _ = error "error parse"

ras :: String -> Expression
ras s = e
  where e = getExp (parse expressionP s)
        
--Q13
                            
data ValeurA = VLitteralA Litteral
             | VFonctionA (ValeurA -> ValeurA) 

--Q14

instance Show ValeurA where
    show (VFonctionA _) = "λ"    
    show (VLitteralA (Entier i)) = show i
    show (VLitteralA (Bool b)) = show b

type Environnement a = [(Nom, a)]
    
--Q15

interpreteA :: Environnement ValeurA -> Expression -> ValeurA
interpreteA _ (Lit l) = VLitteralA l
interpreteA xs (Var k) = fromJust (lookup k xs)
interpreteA xs (Lam nom expr) = VFonctionA (\v -> interpreteA ((nom,v):xs) expr)
interpreteA xs (App e1 e2) = f v2
  where VFonctionA f = interpreteA xs e1
        v2 = interpreteA xs e2

--Q16

negA :: ValeurA
negA = VFonctionA (\(VLitteralA (Entier n)) -> (VLitteralA (Entier (-n))))

--Q17

addA :: ValeurA
addA = VFonctionA (\(VLitteralA (Entier n1)) -> VFonctionA (\(VLitteralA (Entier n2)) -> VLitteralA (Entier (n1 + n2))))

--Q18

releveBinOpEntierA :: (Integer -> Integer -> Integer) -> ValeurA 
releveBinOpEntierA op = VFonctionA (\(VLitteralA (Entier n1)) -> VFonctionA (\(VLitteralA (Entier n2)) -> VLitteralA (Entier (n1 `op` n2))))


envA :: Environnement ValeurA
envA = [ ("neg",   negA)
       , ("add",   releveBinOpEntierA (+))
       , ("soust", releveBinOpEntierA (-))
       , ("mult",  releveBinOpEntierA (*))
       , ("quot",  releveBinOpEntierA quot) ]
       
--Q19
--Pas fini
ifthenelseA :: ValeurA
ifthenelseA = VFonctionA (\(VLitteralA (Bool True)) -> VFonctionA (\(VLitteralA (Entier n1))-> VFonctionA (\(VLitteralA (Entier n2)) -> VLitteralA (Entier n1))))
ifthenelseA = VFonctionA (\(VLitteralA (Bool False)) -> VFonctionA (\(VLitteralA (Entier n1))-> VFonctionA (\(VLitteralA (Entier n2)) -> VLitteralA (Entier n2))))