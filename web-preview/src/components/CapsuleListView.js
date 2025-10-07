import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';

const Container = styled.div`
  padding: 20px;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
`;

const Header = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
`;

const Title = styled.h1`
  color: white;
  font-size: 24px;
  font-weight: 700;
  margin: 0;
`;

const AddButton = styled(motion.button)`
  width: 44px;
  height: 44px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  font-size: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
`;

const CapsuleGrid = styled.div`
  display: grid;
  gap: 16px;
`;

const CapsuleCard = styled(motion.div)`
  background: rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 20px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  cursor: pointer;
`;

const CapsuleName = styled.h3`
  color: white;
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
`;

const CapsuleDate = styled.p`
  color: rgba(255, 255, 255, 0.7);
  margin: 0 0 12px 0;
  font-size: 14px;
`;

const CapsuleStats = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

const Stat = styled.div`
  color: rgba(255, 255, 255, 0.8);
  font-size: 12px;
  
  strong {
    color: white;
    font-weight: 600;
  }
`;

const CountdownBadge = styled.div`
  background: rgba(255, 215, 0, 0.2);
  color: #FFD700;
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 10px;
  font-weight: 600;
`;

const mockCapsules = [
  {
    id: 1,
    name: "Family Vacation 2024",
    unsealDate: "2024-12-25",
    memberCount: 4,
    videoCount: 8,
    daysLeft: 127
  },
  {
    id: 2,
    name: "Sarah's Birthday Surprise",
    unsealDate: "2024-10-15",
    memberCount: 6,
    videoCount: 12,
    daysLeft: 56
  },
  {
    id: 3,
    name: "College Memories",
    unsealDate: "2025-05-20",
    memberCount: 8,
    videoCount: 3,
    daysLeft: 274
  }
];

const CapsuleListView = ({ onNavigate }) => {
  return (
    <Container>
      <Header>
        <Title>My Capsules</Title>
        <AddButton
          onClick={() => onNavigate('newCapsule')}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          +
        </AddButton>
      </Header>
      
      <CapsuleGrid>
        {mockCapsules.map((capsule, index) => (
          <CapsuleCard
            key={capsule.id}
            onClick={() => onNavigate('capsuleDetail')}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <CapsuleName>{capsule.name}</CapsuleName>
            <CapsuleDate>Unseals on {capsule.unsealDate}</CapsuleDate>
            <CapsuleStats>
              <div>
                <Stat><strong>{capsule.memberCount}</strong> members</Stat>
                <Stat><strong>{capsule.videoCount}</strong> videos</Stat>
              </div>
              <CountdownBadge>
                {capsule.daysLeft} days left
              </CountdownBadge>
            </CapsuleStats>
          </CapsuleCard>
        ))}
      </CapsuleGrid>
    </Container>
  );
};

export default CapsuleListView;