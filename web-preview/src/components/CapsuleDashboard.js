import React, { useState, useEffect } from 'react';
import styled, { keyframes } from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';

const breathe = keyframes`
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
`;

const shimmer = keyframes`
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
`;

const Container = styled.div`
  height: 100%;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  overflow-y: auto;
  position: relative;
`;

const FilmGrainOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 50%, transparent 20%, rgba(255,255,255,0.005) 21%, rgba(255,255,255,0.005) 34%, transparent 35%, transparent),
    linear-gradient(0deg, transparent 24%, rgba(255,255,255,0.01) 25%, rgba(255,255,255,0.01) 26%, transparent 27%, transparent 74%, rgba(255,255,255,0.01) 75%, rgba(255,255,255,0.01) 76%, transparent 77%, transparent);
  pointer-events: none;
  mix-blend-mode: overlay;
  z-index: 1;
`;

const TopBar = styled(motion.div)`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  position: relative;
  z-index: 2;
`;

const LogoButton = styled(motion.button)`
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  padding: 8px;
  border-radius: 12px;
  transition: all 0.3s ease;
  
  &:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: scale(1.1);
  }
`;

const CreateButton = styled(motion.button)`
  background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%);
  border: none;
  color: white;
  padding: 12px 20px;
  border-radius: 20px;
  font-weight: 700;
  cursor: pointer;
  font-size: 14px;
  box-shadow: 0 8px 16px rgba(255, 107, 107, 0.4);
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 24px rgba(255, 107, 107, 0.5);
  }
`;

const Section = styled(motion.div)`
  margin-bottom: 32px;
  position: relative;
  z-index: 2;
`;

const SectionTitle = styled(motion.h3)`
  color: white;
  font-size: 24px;
  font-weight: 800;
  margin: 0 0 20px 20px;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
  letter-spacing: -0.5px;
`;

const ActiveCapsulesRow = styled.div`
  display: flex;
  gap: 20px;
  padding: 0 20px;
  overflow-x: auto;
  
  &::-webkit-scrollbar {
    display: none;
  }
  
  scrollbar-width: none;
`;

const ActiveCapsuleCard = styled(motion.div)`
  min-width: 300px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  padding: 24px;
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.15);
  cursor: pointer;
  position: relative;
  overflow: hidden;
  
  &:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.25);
  }
`;

const CardShimmer = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.1),
    transparent
  );
  animation: ${shimmer} 3s infinite;
  opacity: 0.3;
`;

const CapsuleCover = styled(motion.div)`
  width: 100%;
  height: 140px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  border-radius: 16px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  background-image: ${props => props.cover ? `url(${props.cover})` : 'none'};
  background-size: cover;
  background-position: center;
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  position: relative;
  overflow: hidden;
  
  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: radial-gradient(circle at center, transparent 30%, rgba(0,0,0,0.1) 100%);
  }
`;

const CapsuleTitle = styled(motion.h4)`
  color: white;
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 12px 0;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
`;

const CountdownContainer = styled.div`
  text-align: center;
  margin: 20px 0;
  padding: 16px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
  border: 1px solid rgba(255, 215, 0, 0.2);
`;

const CountdownDisplay = styled(motion.div)`
  color: #FFD700;
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 8px;
  text-shadow: 0 2px 8px rgba(255, 215, 0, 0.5);
  filter: drop-shadow(0 0 10px rgba(255, 215, 0, 0.3));
`;

const CountdownLabel = styled.div`
  color: rgba(255, 255, 255, 0.8);
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
`;

const ParticipantFaces = styled(motion.div)`
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
`;

const Face = styled(motion.div)`
  width: 32px;
  height: 32px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  
  &:hover {
    transform: scale(1.1);
    border-color: rgba(255, 255, 255, 0.5);
  }
`;

const MoreFaces = styled.div`
  color: rgba(255, 255, 255, 0.7);
  font-size: 12px;
  font-weight: 600;
  margin-left: 4px;
`;

const QuickRecordButton = styled(motion.button)`
  width: 100%;
  background: linear-gradient(135deg, #FF3B30 0%, #FF6B47 100%);
  border: none;
  color: white;
  padding: 14px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 14px;
  box-shadow: 0 8px 16px rgba(255, 59, 48, 0.4);
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 24px rgba(255, 59, 48, 0.5);
  }
`;

const UnlockedGrid = styled(motion.div)`
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  padding: 0 20px;
`;

const UnlockedCard = styled(motion.div)`
  aspect-ratio: 1;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 20px;
  padding: 20px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  
  &:hover {
    background: rgba(255, 255, 255, 0.12);
    border-color: rgba(255, 255, 255, 0.2);
    transform: translateY(-4px);
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.3);
  }
`;

const UnlockedCover = styled(motion.div)`
  flex: 1;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  margin-bottom: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  position: relative;
  
  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: radial-gradient(circle at center, transparent 40%, rgba(255,255,255,0.05) 100%);
  }
`;

const UnlockedTitle = styled(motion.h5)`
  color: white;
  font-size: 16px;
  font-weight: 700;
  margin: 0 0 4px 0;
  text-shadow: 0 1px 2px rgba(0,0,0,0.5);
`;

const UnlockedDate = styled(motion.p)`
  color: rgba(255, 255, 255, 0.7);
  font-size: 12px;
  margin: 0;
  font-weight: 500;
`;

const EmptyState = styled(motion.div)`
  padding: 60px 20px;
  text-align: center;
  position: relative;
  z-index: 2;
`;

const EmptyCard = styled(motion.div)`
  background: rgba(255, 255, 255, 0.05);
  border: 2px dashed rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 50px 30px;
  margin-bottom: 30px;
  backdrop-filter: blur(10px);
  position: relative;
  overflow: hidden;
`;

const EmptyIcon = styled(motion.div)`
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.8;
`;

const EmptyTitle = styled(motion.h4)`
  color: white;
  font-size: 24px;
  font-weight: 800;
  margin: 0 0 12px 0;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
`;

const EmptySubtitle = styled(motion.p)`
  color: rgba(255, 255, 255, 0.8);
  font-style: italic;
  margin: 0 0 30px 0;
  font-size: 16px;
  line-height: 1.4;
`;

const FAB = styled(motion.button)`
  position: fixed;
  bottom: 30px;
  left: 50%;
  transform: translateX(-50%);
  width: 72px;
  height: 72px;
  border-radius: 36px;
  background: linear-gradient(135deg, #FF3B30 0%, #FF6B47 100%);
  border: none;
  color: white;
  font-size: 28px;
  cursor: pointer;
  box-shadow: 
    0 12px 32px rgba(255, 59, 48, 0.4),
    0 4px 8px rgba(0, 0, 0, 0.2);
  z-index: 100;
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateX(-50%) translateY(-4px) scale(1.05);
    box-shadow: 
      0 16px 40px rgba(255, 59, 48, 0.5),
      0 8px 16px rgba(0, 0, 0, 0.3);
  }
`;

const FloatingElements = styled.div`
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
`;

const FloatingDot = styled(motion.div)`
  position: absolute;
  width: 6px;
  height: 6px;
  background: rgba(255, 215, 0, 0.3);
  border-radius: 50%;
`;

// Mock data with more realistic content
const activeCapsules = [
  {
    id: 1,
    title: "Summer Road Trip 2024",
    unlockDate: new Date('2024-12-25T10:00:00'),
    participants: ["👩", "👨", "👱‍♀️", "😊"],
    cover: null,
    clipCount: 12
  },
  {
    id: 2,
    title: "Sarah's 25th Birthday",
    unlockDate: new Date('2024-10-15T18:00:00'),
    participants: ["👩", "👨", "👱‍♀️", "👴", "👵", "🧒"],
    cover: null,
    clipCount: 8
  }
];

const unlockedCapsules = [
  { id: 3, title: "College Graduation", unlockedDate: "May 2024", cover: "🎓" },
  { id: 4, title: "Hawaii Vacation", unlockedDate: "Aug 2024", cover: "🏖️" },
  { id: 5, title: "New Year's Eve", unlockedDate: "Jan 2024", cover: "🎆" },
  { id: 6, title: "Family Reunion", unlockedDate: "Jul 2024", cover: "👨‍👩‍👧‍👦" }
];

const CapsuleDashboard = ({ onNavigate }) => {
  const [countdowns, setCountdowns] = useState({});
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    
    const updateCountdowns = () => {
      const newCountdowns = {};
      activeCapsules.forEach(capsule => {
        const now = new Date();
        const diff = capsule.unlockDate - now;
        
        if (diff > 0) {
          const days = Math.floor(diff / (1000 * 60 * 60 * 24));
          const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
          const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
          
          if (days > 0) {
            newCountdowns[capsule.id] = { value: days, unit: days === 1 ? 'day' : 'days' };
          } else if (hours > 0) {
            newCountdowns[capsule.id] = { value: hours, unit: hours === 1 ? 'hour' : 'hours' };
          } else {
            newCountdowns[capsule.id] = { value: minutes, unit: minutes === 1 ? 'minute' : 'minutes' };
          }
        } else {
          newCountdowns[capsule.id] = { value: 'UNLOCKED!', unit: '' };
        }
      });
      setCountdowns(newCountdowns);
    };

    updateCountdowns();
    const interval = setInterval(updateCountdowns, 60000);
    
    return () => clearInterval(interval);
  }, []);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        duration: 0.6,
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5, ease: "easeOut" }
    }
  };

  return (
    <Container>
      <FilmGrainOverlay />
      
      <FloatingElements>
        {[...Array(8)].map((_, i) => (
          <FloatingDot
            key={i}
            animate={{
              x: [0, Math.random() * 100 - 50],
              y: [0, Math.random() * 100 - 50],
              opacity: [0.2, 0.6, 0.2]
            }}
            transition={{
              duration: 6 + Math.random() * 4,
              repeat: Infinity,
              delay: Math.random() * 3
            }}
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`
            }}
          />
        ))}
      </FloatingElements>

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate={mounted ? "visible" : "hidden"}
      >
        <TopBar variants={itemVariants}>
          <LogoButton
            whileHover={{ scale: 1.1, rotate: 5 }}
            whileTap={{ scale: 0.95 }}
          >
            🎬
          </LogoButton>
          <CreateButton
            onClick={() => onNavigate('newCapsule')}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            + Create Capsule
          </CreateButton>
        </TopBar>

        {activeCapsules.length > 0 ? (
          <Section variants={itemVariants}>
            <SectionTitle>Active Capsules</SectionTitle>
            <ActiveCapsulesRow>
              {activeCapsules.map((capsule, index) => (
                <ActiveCapsuleCard
                  key={capsule.id}
                  onClick={() => onNavigate('capsuleDetail')}
                  initial={{ opacity: 0, x: 100 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.2 }}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <CardShimmer />
                  
                  <CapsuleCover 
                    cover={capsule.cover}
                    whileHover={{ scale: 1.02 }}
                  >
                    🎥
                  </CapsuleCover>
                  
                  <CapsuleTitle>{capsule.title}</CapsuleTitle>
                  
                  <CountdownContainer>
                    <CountdownDisplay
                      key={countdowns[capsule.id]?.value}
                      animate={{ scale: [1, 1.05, 1] }}
                      transition={{ duration: 0.5 }}
                    >
                      {countdowns[capsule.id]?.value || '...'}
                    </CountdownDisplay>
                    <CountdownLabel>
                      {countdowns[capsule.id]?.unit || 'loading...'}
                    </CountdownLabel>
                  </CountdownContainer>
                  
                  <ParticipantFaces>
                    {capsule.participants.slice(0, 5).map((face, i) => (
                      <Face 
                        key={i}
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        transition={{ delay: 0.5 + i * 0.1 }}
                        whileHover={{ scale: 1.2 }}
                      >
                        {face}
                      </Face>
                    ))}
                    {capsule.participants.length > 5 && (
                      <MoreFaces>+{capsule.participants.length - 5}</MoreFaces>
                    )}
                  </ParticipantFaces>
                  
                  <QuickRecordButton 
                    onClick={(e) => {
                      e.stopPropagation();
                      onNavigate('record');
                    }}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    ⏺️ Quick Record
                  </QuickRecordButton>
                </ActiveCapsuleCard>
              ))}
            </ActiveCapsulesRow>
          </Section>
        ) : (
          <EmptyState variants={itemVariants}>
            <EmptyCard
              whileHover={{ scale: 1.02 }}
            >
              <EmptyIcon
                animate={{ rotate: [0, 5, -5, 0] }}
                transition={{ duration: 4, repeat: Infinity }}
              >
                📹
              </EmptyIcon>
              <EmptyTitle>Create your first capsule</EmptyTitle>
              <EmptySubtitle>Shoot it. Seal it. Share it later.</EmptySubtitle>
              <CreateButton 
                onClick={() => onNavigate('newCapsule')}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                Create Capsule
              </CreateButton>
            </EmptyCard>
          </EmptyState>
        )}

        {unlockedCapsules.length > 0 && (
          <Section variants={itemVariants}>
            <SectionTitle>Your Story Archive</SectionTitle>
            <UnlockedGrid>
              {unlockedCapsules.map((capsule, index) => (
                <UnlockedCard
                  key={capsule.id}
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <UnlockedCover
                    whileHover={{ scale: 1.05 }}
                  >
                    {capsule.cover}
                  </UnlockedCover>
                  <div>
                    <UnlockedTitle>{capsule.title}</UnlockedTitle>
                    <UnlockedDate>{capsule.unlockedDate}</UnlockedDate>
                  </div>
                </UnlockedCard>
              ))}
            </UnlockedGrid>
          </Section>
        )}
      </motion.div>

      <FAB
        onClick={() => onNavigate('record')}
        animate={{ 
          boxShadow: [
            "0 12px 32px rgba(255, 59, 48, 0.4)",
            "0 12px 32px rgba(255, 59, 48, 0.6)",
            "0 12px 32px rgba(255, 59, 48, 0.4)"
          ]
        }}
        transition={{ duration: 2, repeat: Infinity }}
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
      >
        ⏺️
      </FAB>
    </Container>
  );
};

export default CapsuleDashboard;